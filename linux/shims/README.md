# shims/

Small native DLLs that work around specific Wine compatibility gaps in the
game's own hook DLLs. Not ports of anything - these don't exist in the
original Windows-only pipeline at all.

## ntquery_shim.dll

Fixes `App/zh/fgozh.dll` (the Chinese/English resource hook - the mechanism
this whole patch depends on) failing to initialize under Wine. See the
comment at the top of `ntquery_shim.c` for the full root-cause explanation
and fix approach (Wine's `ntdll.dll` doesn't implement
`NtQueryInformationByName`; this patches ntdll's own Export Address Table so
`GetProcAddress(ntdll, "NtQueryInformationByName")` returns a safe stub
instead of `NULL`).

Wired into `linux/fgo-launcher.sh` automatically as the first `-k` argument,
if the compiled `.dll` is present.

### Rebuilding

```sh
pacman -S mingw-w64-gcc   # Arch/CachyOS; any x86_64-w64-mingw32-gcc works
x86_64-w64-mingw32-gcc -shared -O2 -Wall -o ntquery_shim.dll ntquery_shim.c -lkernel32 -luser32
```

Add `-DNTQUERY_SHIM_DEBUG` to log every step to `Z:\tmp\shim-debug.log`
(`/tmp/shim-debug.log` through the usual `z:` → `/` wine drive mapping) -
this is how the original investigation found and fixed the trampoline bug
(a naive cross-module RVA wrapped around to garbage when this DLL happened
to load at a lower address than the target module).

## feedback_shim.dll

Fixes `ago.exe` hard-aborting shortly after startup: `wine: Call from ... to
unimplemented function USER32.dll.SetWindowFeedbackSetting, aborting`. See
the comment at the top of `feedback_shim.c` for the full explanation -
unlike `ntquery_shim.dll`'s case (a *dynamic* `GetProcAddress` lookup made
from inside another DLL's own `DllMain`), this is a *static* import of
`ago.exe` itself, resolved by the PE loader before any `-k` injected DLL's
`DllMain` runs. The fix walks `ago.exe`'s own Import Address Table directly
and overwrites the one slot for `SetWindowFeedbackSetting` with a stub that
returns `TRUE` - simpler than the EAT-patching trampoline trick above, since
an IAT slot already holds a full pointer rather than a module-relative RVA.

Wired into `linux/fgo-launcher.sh` automatically alongside `ntquery_shim.dll`,
if the compiled `.dll` is present. Order relative to the other `-k` DLLs
doesn't matter - it patches `ago.exe`'s own import table directly, not
something another injected DLL depends on.

### Rebuilding

```sh
x86_64-w64-mingw32-gcc -shared -O2 -Wall -o feedback_shim.dll feedback_shim.c -lkernel32 -luser32
```

Add `-DFEEDBACK_SHIM_DEBUG` to log every step to `Z:\tmp\feedback-shim-debug.log`,
same pattern as `ntquery_shim.dll`'s debug flag.
