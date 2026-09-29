/* Workaround for ago.exe hard-aborting on startup:
 *
 *   wine: Call from <addr> to unimplemented function
 *   USER32.dll.SetWindowFeedbackSetting, aborting
 *
 * `SetWindowFeedbackSetting` (Windows 10 1607+, configures the touch/pen
 * visual feedback for a window) is a *static* import of ago.exe itself -
 * unlike ntquery_shim.c's case (a dynamic GetProcAddress lookup made from
 * inside another DLL's own DllMain), this one is resolved by the PE loader
 * when ago.exe's image is first mapped, long before any -k injected DLL's
 * DllMain gets to run. Wine's user32.dll doesn't implement it, so Wine's
 * loader binds the Import Address Table slot to its own "unimplemented,
 * calling this aborts the process" trampoline instead of leaving it NULL.
 * By the time this shim runs, that trampoline is already sitting in
 * ago.exe's IAT; the only way to stop the abort is to overwrite that one
 * IAT slot before the game actually calls through it.
 *
 * This is simpler than ntquery_shim.c's fix even though the goal is
 * similar: an Import Address Table slot holds a full pointer already (not
 * a module-relative RVA like an Export Address Table entry), so there's no
 * ASLR/near-allocation trampoline to build - just find ago.exe's own
 * import descriptor for USER32.dll, find the thunk pair for this one name,
 * and overwrite the address thunk directly.
 *
 * The stub returns TRUE (success) and does nothing else. This setting only
 * controls optional visual/haptic touch feedback - pretending it succeeded
 * is safe.
 */
#include <windows.h>
#include <string.h>

#ifdef FEEDBACK_SHIM_DEBUG
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
    h = CreateFileA("Z:\\tmp\\feedback-shim-debug.log", FILE_APPEND_DATA, FILE_SHARE_READ | FILE_SHARE_WRITE,
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

static BOOL WINAPI Stub_SetWindowFeedbackSetting(
    HWND hwnd, DWORD feedback, DWORD flags, UINT32 size, const void *configuration)
{
    (void)hwnd; (void)feedback; (void)flags; (void)size; (void)configuration;
    return TRUE;
}

static void patch_iat(void)
{
    BYTE *base = (BYTE *)GetModuleHandleA(NULL);
    IMAGE_DOS_HEADER *dos = (IMAGE_DOS_HEADER *)base;
    IMAGE_NT_HEADERS *nt;
    IMAGE_DATA_DIRECTORY import_dir;
    IMAGE_IMPORT_DESCRIPTOR *imp;
    DWORD old_protect;

    dbg("main module base=%p", (void *)base);
    if (dos->e_magic != IMAGE_DOS_SIGNATURE) { dbg("abort: bad DOS signature"); return; }
    nt = (IMAGE_NT_HEADERS *)(base + dos->e_lfanew);
    if (nt->Signature != IMAGE_NT_SIGNATURE) { dbg("abort: bad NT signature"); return; }
    import_dir = nt->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT];
    if (import_dir.VirtualAddress == 0) { dbg("abort: no import directory"); return; }
    imp = (IMAGE_IMPORT_DESCRIPTOR *)(base + import_dir.VirtualAddress);

    for (; imp->Name != 0; imp++) {
        const char *dll_name = (const char *)(base + imp->Name);
        IMAGE_THUNK_DATA *name_thunk, *addr_thunk;

        dbg("import descriptor: %s", dll_name);
        if (lstrcmpiA(dll_name, "USER32.dll") != 0) continue;

        name_thunk = (IMAGE_THUNK_DATA *)(base + (imp->OriginalFirstThunk ? imp->OriginalFirstThunk : imp->FirstThunk));
        addr_thunk = (IMAGE_THUNK_DATA *)(base + imp->FirstThunk);

        for (; name_thunk->u1.AddressOfData != 0; name_thunk++, addr_thunk++) {
            IMAGE_IMPORT_BY_NAME *by_name;
            if (name_thunk->u1.Ordinal & IMAGE_ORDINAL_FLAG) continue; /* imported by ordinal, no name to match */
            by_name = (IMAGE_IMPORT_BY_NAME *)(base + name_thunk->u1.AddressOfData);
            if (lstrcmpA((LPCSTR)by_name->Name, "SetWindowFeedbackSetting") == 0) {
                dbg("found SetWindowFeedbackSetting, old thunk=%p, patching to stub=%p",
                    (void *)(ULONG_PTR)addr_thunk->u1.Function, (void *)Stub_SetWindowFeedbackSetting);
                VirtualProtect(&addr_thunk->u1.Function, sizeof(addr_thunk->u1.Function), PAGE_READWRITE, &old_protect);
                addr_thunk->u1.Function = (ULONG_PTR)(void *)Stub_SetWindowFeedbackSetting;
                VirtualProtect(&addr_thunk->u1.Function, sizeof(addr_thunk->u1.Function), old_protect, &old_protect);
                dbg("patched");
                return;
            }
        }
        dbg("abort: USER32.dll import descriptor found but SetWindowFeedbackSetting not among its thunks");
        return;
    }
    dbg("abort: no USER32.dll import descriptor found");
}

BOOL WINAPI DllMain(HINSTANCE hinst, DWORD reason, LPVOID reserved)
{
    (void)reserved;
    if (reason == DLL_PROCESS_ATTACH) {
        DisableThreadLibraryCalls(hinst);
        patch_iat();
    }
    return TRUE;
}
