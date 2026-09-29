/* Workaround for fgozh.dll (and any other -k DLL) failing to init under Wine
 * because Wine's ntdll.dll doesn't implement NtQueryInformationByName (a
 * Windows 10 2004+ addition). Confirmed via disassembly: fgozh.dll resolves
 * five ntdll functions as a group and aborts DllMain if ANY GetProcAddress
 * call in that group returns NULL - NtCreateFile, NtOpenFile,
 * NtQueryAttributesFile and NtQueryFullAttributesFile are long-standing Wine
 * exports (fine); only NtQueryInformationByName is missing.
 *
 * Fix: patch ntdll's *own* Export Address Table entry for GetProcAddress so
 * it points at our wrapper instead of the real implementation. Any module
 * whose imports get resolved by the loader *after* this DLL is injected
 * (fgozh.dll, injected via a later -k argument) picks up our wrapper
 * automatically - no per-target-module patching, no inline code hooking, no
 * instruction-boundary/relocation concerns. Modules already loaded before
 * this DLL (ago.exe itself, fgohook.dll if it precedes us) keep whatever
 * they already resolved and are unaffected.
 *
 * The wrapper only intercepts GetProcAddress(ntdll_handle,
 * "NtQueryInformationByName"); every other lookup passes straight through
 * to the real GetProcAddress. The stub it returns sets a NOT_IMPLEMENTED
 * NTSTATUS and touches nothing else - safe as long as the caller checks the
 * status (standard NTAPI convention), but not verified against fgozh.dll's
 * actual use of the result (no source, only disassembly of the resolution
 * gate itself).
 */
#include <windows.h>
#include <tlhelp32.h>
#include <string.h>

/* Build with -DNTQUERY_SHIM_DEBUG to log every step to Z:\tmp\shim-debug.log
 * (i.e. /tmp/shim-debug.log through a wine drive mapping to /) - this is how
 * the 2026-09-17 investigation found the trampoline bug (see linux/NOTES or
 * git history). Off by default: no per-call disk I/O in normal use. */
#ifdef NTQUERY_SHIM_DEBUG
#include <stdarg.h>
static void dbg(const char *fmt, ...)
{
    char buf[512];
    va_list args;
    HANDLE h;
    DWORD written;
    va_start(args, fmt);
    wvsprintfA(buf, fmt, args);
    va_end(args);
    h = CreateFileA("Z:\\tmp\\shim-debug.log", FILE_APPEND_DATA, FILE_SHARE_READ | FILE_SHARE_WRITE,
                     NULL, OPEN_ALWAYS, FILE_ATTRIBUTE_NORMAL, NULL);
    if (h != INVALID_HANDLE_VALUE) {
        WriteFile(h, buf, lstrlenA(buf), &written, NULL);
        WriteFile(h, "\r\n", 2, &written, NULL);
        CloseHandle(h);
    }
}
#else
static void dbg(const char *fmt, ...) { (void)fmt; }
#endif

typedef FARPROC (WINAPI *GetProcAddress_t)(HMODULE, LPCSTR);
static GetProcAddress_t real_GetProcAddress;
static HMODULE ntdll_handle;

static LONG NTAPI Fake_NtQueryInformationByName(
    PVOID ObjectAttributes, PVOID IoStatusBlockPtr, PVOID FileInformation,
    ULONG Length, ULONG FileInformationClass)
{
    struct { LONG_PTR Status; ULONG_PTR Information; } *iosb = IoStatusBlockPtr;
    const LONG STATUS_NOT_IMPLEMENTED = (LONG)0xC0000002L;
    (void)ObjectAttributes; (void)FileInformation; (void)Length; (void)FileInformationClass;
    if (iosb) {
        iosb->Status = STATUS_NOT_IMPLEMENTED;
        iosb->Information = 0;
    }
    return STATUS_NOT_IMPLEMENTED;
}

static FARPROC WINAPI Hooked_GetProcAddress(HMODULE hModule, LPCSTR lpProcName)
{
    if (hModule == ntdll_handle && (ULONG_PTR)lpProcName > 0xFFFF) {
        dbg("Hooked_GetProcAddress(ntdll, \"%s\")", lpProcName);
        if (lstrcmpA(lpProcName, "NtQueryInformationByName") == 0) {
            dbg("  -> returning fake stub");
            return (FARPROC)(void *)Fake_NtQueryInformationByName;
        }
    }
    return real_GetProcAddress(hModule, lpProcName);
}

/* An Export Address Table entry is a 32-bit RVA - it can only express an
 * address *at or above* the module's own base, within 4GB. Our own code
 * lives in a different module at a base ASLR places arbitrarily (observed:
 * sometimes below the target module, where no RVA can represent it at all).
 * Allocate a tiny absolute-jump trampoline within range of target_base
 * instead of pointing the export slot at our function directly. */
static void *alloc_trampoline_near(BYTE *target_base, void *real_target)
{
    SYSTEM_INFO si;
    UINT_PTR gran, start, delta;
    void *mem = NULL;
    BYTE stub[12] = { 0x48, 0xB8, 0,0,0,0,0,0,0,0, 0xFF, 0xE0 }; /* mov rax,imm64; jmp rax */

    GetSystemInfo(&si);
    gran = si.dwAllocationGranularity;
    start = ((UINT_PTR)target_base) & ~(gran - 1);
    for (delta = 0; delta < 0x70000000; delta += gran) {
        mem = VirtualAlloc((void *)(start + delta), 4096, MEM_RESERVE | MEM_COMMIT, PAGE_EXECUTE_READWRITE);
        if (mem) break;
    }
    if (!mem) { dbg("abort: could not allocate a trampoline page near target_base"); return NULL; }

    *(void **)(stub + 2) = real_target;
    memcpy(mem, stub, sizeof(stub));
    dbg("trampoline at %p -> %p (target_base=%p, delta=0x%lx)", mem, real_target, (void *)target_base, (unsigned long)((BYTE *)mem - target_base));
    return mem;
}

static void patch_export_table(void)
{
    HANDLE snap;
    MODULEENTRY32 me;
    BYTE *target_base = NULL;
    void *trampoline;
    DWORD target_rva, wrapper_rva, i, old_protect;
    IMAGE_DOS_HEADER *dos;
    IMAGE_NT_HEADERS *nt;
    IMAGE_DATA_DIRECTORY export_dir;
    IMAGE_EXPORT_DIRECTORY *exports;
    DWORD *functions;

    real_GetProcAddress = (GetProcAddress_t)GetProcAddress(GetModuleHandleA("kernel32.dll"), "GetProcAddress");
    ntdll_handle = GetModuleHandleA("ntdll.dll");
    dbg("real_GetProcAddress=%p ntdll_handle=%p", (void *)real_GetProcAddress, (void *)ntdll_handle);
    if (!real_GetProcAddress || !ntdll_handle) { dbg("abort: missing real_GetProcAddress or ntdll_handle"); return; }

    snap = CreateToolhelp32Snapshot(TH32CS_SNAPMODULE | TH32CS_SNAPMODULE32, GetCurrentProcessId());
    if (snap == INVALID_HANDLE_VALUE) { dbg("abort: CreateToolhelp32Snapshot failed, err=%lu", GetLastError()); return; }
    me.dwSize = sizeof(me);
    if (Module32First(snap, &me)) {
        do {
            dbg("module %s base=%p size=%lu", me.szModule, (void *)me.modBaseAddr, me.modBaseSize);
            if ((BYTE *)real_GetProcAddress >= me.modBaseAddr &&
                (BYTE *)real_GetProcAddress < me.modBaseAddr + me.modBaseSize) {
                target_base = me.modBaseAddr;
            }
        } while (Module32Next(snap, &me));
    }
    CloseHandle(snap);
    dbg("target_base=%p", (void *)target_base);
    if (!target_base) { dbg("abort: real_GetProcAddress not inside any snapshotted module"); return; }

    dos = (IMAGE_DOS_HEADER *)target_base;
    if (dos->e_magic != IMAGE_DOS_SIGNATURE) { dbg("abort: bad DOS signature"); return; }
    nt = (IMAGE_NT_HEADERS *)(target_base + dos->e_lfanew);
    if (nt->Signature != IMAGE_NT_SIGNATURE) { dbg("abort: bad NT signature"); return; }
    export_dir = nt->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_EXPORT];
    if (export_dir.VirtualAddress == 0) { dbg("abort: no export directory"); return; }
    exports = (IMAGE_EXPORT_DIRECTORY *)(target_base + export_dir.VirtualAddress);
    functions = (DWORD *)(target_base + exports->AddressOfFunctions);

    trampoline = alloc_trampoline_near(target_base, (void *)Hooked_GetProcAddress);
    if (!trampoline) return;

    target_rva = (DWORD)((BYTE *)real_GetProcAddress - target_base);
    wrapper_rva = (DWORD)((BYTE *)trampoline - target_base);
    dbg("target_rva=0x%lx wrapper_rva=0x%lx NumberOfFunctions=%lu export_dir=[0x%lx,0x%lx)",
        target_rva, wrapper_rva, exports->NumberOfFunctions,
        export_dir.VirtualAddress, export_dir.VirtualAddress + export_dir.Size);
    /* Guard against the (astronomically unlikely) case that our trampoline's
     * RVA lands inside the export directory itself, which would make the
     * loader treat it as a forwarder string instead of a code address. */
    if (wrapper_rva >= export_dir.VirtualAddress &&
        wrapper_rva < export_dir.VirtualAddress + export_dir.Size) {
        dbg("abort: wrapper_rva falls inside export directory range");
        return;
    }

    for (i = 0; i < exports->NumberOfFunctions; i++) {
        if (functions[i] == target_rva) {
            dbg("match at export index %lu (old rva=0x%lx), patching to 0x%lx", i, functions[i], wrapper_rva);
            VirtualProtect(&functions[i], sizeof(DWORD), PAGE_READWRITE, &old_protect);
            functions[i] = wrapper_rva;
            VirtualProtect(&functions[i], sizeof(DWORD), old_protect, &old_protect);
            dbg("patched, verify functions[%lu]=0x%lx", i, functions[i]);
            return;
        }
    }
    dbg("abort: no export table slot matched target_rva=0x%lx", target_rva);
}

BOOL WINAPI DllMain(HINSTANCE hinst, DWORD reason, LPVOID reserved)
{
    (void)reserved;
    if (reason == DLL_PROCESS_ATTACH) {
        DisableThreadLibraryCalls(hinst);
        patch_export_table();
    }
    return TRUE;
}
