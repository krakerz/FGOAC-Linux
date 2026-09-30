# FGOAC-Linux

Run a Cloud23333 FGO Arcade install natively on Linux under Wine/Proton, with a native settings GUI and bash replacements for its PowerShell scripts.

## Description

The distribution's PowerShell scripts use Windows-only subsystems (WMI, Service Control Manager, WinForms) that Wine doesn't implement. This repo replaces them with bash/Python and adds a native GUI. This repo contains only the Linux scripts (`linux/`, `fgo-gui.sh`); the game itself (App/, Server/, DEVICE/, etc.) is Cloud23333's distribution and is never included here. You need your own existing FGO Arcade install.

## Features

- Native settings GUI (`./fgo-gui.sh`) with tabs: Setup, Game Settings (Basic / Advanced Graphics / Audio), Controls (Keyboard / Controller XInput with live button capture), Server (start/stop/restart), Account, Deck (card-art grid, deck builder), Draw Rates (with presets), Banners. Reads/writes the same files scooby does, so both stay interchangeable.
- One-click launch: starts the local ARTEMiS server automatically and stops it when the game exits.
- Optional gamescope: windowed or fullscreen, optional AMD FSR upscaling.
- Graphics: render scale up to 200% (supersampling against jagged edges), SMAA, anisotropic filtering, shadow resolution.
- Target FPS 60, or 120 (experimental - uses a one-byte-patched copy of fgohook.dll, the original stays untouched; higher GPU load, menus/touch may misbehave).
- "Live log in a terminal" option: opens your terminal with the game's log in real time (handy when the GUI is started by double-click).
- Self-healing on every launch: GPU compatibility (Mesa driconf entry in `~/.drirc`, missing DLLs), shader cache kept outside the install so reinstalls don't recompile shaders.
- English text patch apply/revert.
- Photo mode (built into the game's hook): F9 enter/exit, WASD move, Q/E down/up, arrow keys turn/look, Z/C roll, R reset camera, F10 hide UI. Keys are rebindable in Game Settings > Photo Mode, and its live panel adjusts FOV, move speed and depth of field while you shoot.

## Installation

**Requirements:**
- An existing FGO Arcade install
- Proton build's wine (plain system wine does not work for this game)
- python3 with tkinter and Pillow (python-evdev optional for gamepad capture)
- curl, flock, pgrep (standard)
- Optional: gamescope, zenity

Run:
```sh
linux/setup.sh --install-root "/path/to/FGO Arcade" --wineprefix /path/to/wine/prefix
```

Writes `linux/fgo.env` and creates the Python venv the server needs. Safe to re-run.

## Building from source

Nothing to build for normal use; the Wine helpers in `linux/shims/` (shim DLLs and the photo-mode bridge) ship precompiled. Only if you change one of their `.c` files: install mingw and see `linux/shims/README.md` for the exact command.

## Usage

```sh
./fgo-gui.sh
```

Configure the Setup tab once, then Save & Play.

Without the GUI:
```sh
linux/fix-server-config.sh        # sync server ports/database config
linux/apply-en-patch.sh           # English patch
linux/start-fgo-local-server.sh   # server only; the launcher normally starts it
linux/fgo-launcher.sh             # launch the game
```

Every setting is documented in `linux/fgo.env.example`.

## FAQ

**"Communication error" after scanning the card?**
The local server must be running (Save & Play starts it). If it persists, your account data may have been replaced; older copies are kept as `Server/state/fgo-players.json.bak-*` in the install.

**Low FPS, heavy GPU load, or lip-sync out of sync?**
Check that your GPU isn't pinned to a low power/clock profile (for example a LACT or power-saving profile). A healthy session holds 60 FPS with modest GPU load.

**Jagged edges?**
Set Render scale to 200% (Game Settings -> Advanced Graphics).

**Lobby background looks shifted on an ultrawide resolution?**
The game's compatibility hook only partly supports 21:9. Use a 16:9 resolution (optionally upscaled with gamescope) for a clean image.

**Can I use keyboard and gamepad at the same time?**
The game takes one input mode at launch. Use keyboard mode and map the gamepad to keys with a tool such as AntiMicroX.

**Can the game run above 60 FPS?**
Only via the experimental 120 option; the hook's high-FPS mode is only partly compatible with this game build.

## Credits

- Cloud23333 - the FGO Arcade distribution this runs, including its compatibility hook (fgohook) and English-patch payload.
- scooby (FGOAC scooby launcher) - the Windows launcher this GUI mirrors; reference for its features and data formats.
- segatools - upstream base of the arcade I/O hooks.

---

### Notes

Built and maintained with the help of AI.
