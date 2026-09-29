# Vanilla segatools fgohook.dll experiment

Built 2026-09-17 from `https://gitea.tendokyu.moe/Haruka/segatools`
(`develop` branch) to test whether it avoids the `io4` HID-enumeration
crash the real distributed `fgohook.dll` hits (see the project's NOTES.md
for that whole investigation).

## Build steps (for rebuilding)

```sh
git clone --depth 1 -b develop https://gitea.tendokyu.moe/Haruka/segatools.git
cd segatools
meson setup build --cross-file cross-mingw-64.txt --buildtype=release
meson configure build -Dc_args=-Wno-error  # GCC 16 is stricter than upstream's CI expects
ninja -C build games/fgohook/fgohook.dll
```

Output: `build/games/fgohook/fgohook.dll`.

## Result

**Confirmed: this vanilla build never hits the `io4`/`hid_joystick_device_try_open`
crash at all** - a real, useful diagnostic result, since it proves that
crash is specific to something in the actual distributed `fgohook.dll`'s
extra code, not a Wine bug in the shared parts of segatools this vanilla
build still has (io4, XInput reading, etc. - all present here too).

**But it doesn't work as a drop-in replacement**: the distributed
`fgohook.dll` is a heavily customized private fork with extensive
FGO-Arcade-specific resolution/graphics remapping (`Resolution mode: ...`,
`Formation: ...`, `TOUCH: exact remapped canvas ...` - none of that exists
in vanilla segatools). Without it, `ago.exe`'s own window creation gets a
`BadValue`/`X_CreateWindow` X11 error (window size `0x0`) and exits -
reproduced at both the user's native ultrawide resolution (3440x1440) and
a standard 1920x1080, so it's not a resolution-specific edge case, just a
genuinely missing piece of window-setup logic this vanilla build doesn't
have.

## How this was tested

Backed up the real `App/fgohook.dll`, temporarily replaced it with this
build, ran `linux/fgo-launcher.sh` for real (local server up), confirmed
the new crash, then restored the original file (verified via sha256sum
before continuing). The live install is back to its original state.

## Update 2026-09-17: window-creation bug found and fixed

The "zero-sized window" read above was wrong - disproven by adding debug
`dprintf`s to `hook_CreateWindowExA` (entry and just before the real
`next_CreateWindowExA` call). Actual trace from a live run:

```
Gfx: CreateWindowExA hook hit (requested 2568x1474 at -2147483648,0, style=10cf0000)
Gfx: CreateWindowExA final call: class=Fate/Grand Order Arcade 2568x1474 at -2147483648,0, style=80000000 exstyle=00000000 parent=0000000000000000 menu=0000000000000000
Touch: Hook window proc (A)
Touch: Hook window proc (W)
```

Both requested and final width/height are sane and non-zero, X is
`CW_USEDEFAULT`, style correctly downgrades to `WS_POPUP` (borderless), and
the window class registration/subclassing (`Touch: Hook window proc`)
completes for both the ANSI and Wide window procs. **The window is created
successfully.** The `X Error ... BadValue (X_CreateWindow) ... Value in
failed request: 0x0` seen in the log is unrelated - it happens *before*
this hook ever fires (no preceding `Gfx:` line), so it's some other,
already-confirmed-non-fatal 0x0-sized window from Wine's own internal
setup (see NOTES.md - Wine's `x11drv` error_handler explicitly logs some
X errors as "ignored" and keeps going). The game's actual window is fine.

With this build, `ago.exe` now runs measurably further than with the real
distributed `fgohook.dll`: past window creation, into registry probing and
real DirectInput joystick device enumeration
(`fixme:dinput:hid_joystick_device_try_open`) - before hitting:

```
Debugger: unhandled exception 0xc0000005 at 0000000000000000 (pid=272, tid=276)
Debugger: process exited (pid=272, tid=276, code=0xc0000005)
```

This is the **same pre-existing, already root-caused crash** documented in
the project TODO.md ("BLOCKING, unresolved" item) - confirmed by PE-header
address comparison to be inside `ago.exe`'s own closed-source code, not
segatools/fgohook, not Wine. It happens right after DirectInput enumerates
the real, physically-attached controller (a GameSir T4 Kaleid, currently
plugged in as an Xbox360-compatible device). Every mitigation for this
specific crash was already exhaustively tried and ruled out in an earlier
investigation pass (`DisableHidraw`, per-device Joystick exclusion,
unplugging the controller, `FGO_IO4_ENABLE=0`, live GDB attach) - so there's
no new angle to try here; it's a separate, harder blocker than the
gfxhook window bug this experiment set out to fix.

**Conclusion: the fgohook debugging task is done.** Vanilla segatools'
`common/gfxhook/gfx.c` window creation works correctly as-is - no bug to
fix there after all; the earlier "zero-sized window" theory was a
misread caused by X11's asynchronous error reporting. The remaining
blocker to a playable game is the unrelated native `ago.exe` HID/joystick
crash. Using this vanilla build as a permanent replacement still means
losing the real fork's FGO-specific features (GP lock/unlimited resources,
damage number UI scaling, deck management hooks, story skip, BGM easter
egg, resolution remapping) for no net benefit right now, since the game
still can't reach a playable state either way. Live install's
`fgohook.dll` restored to the original (sha256 `1111e2c0...` verified)
after this test.
