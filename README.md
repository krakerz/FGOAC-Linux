# FGOAC-Linux

Run a Cloud23333 FGO Arcade install natively on Linux under Wine/Proton, with a native settings GUI and bash replacements for its PowerShell scripts.

## Description

The distribution's PowerShell scripts use Windows-only subsystems (WMI, Service Control Manager, WinForms) that Wine doesn't implement. This repo replaces them with bash/Python and adds a native GUI. This repo contains only the Linux scripts (`linux/`, `fgo-gui.sh`); the game itself (App/, Server/, DEVICE/, etc.) is Cloud23333's distribution and is never included here. You need your own existing FGO Arcade install.

## Features

- Native settings GUI (`./fgo-gui.sh`) with tabs: Setup, Game Settings (Basic / Advanced Graphics / Audio), Controls (Keyboard / Controller XInput with live button capture), Server (start/stop/restart, database check and init, billing report time), Account, Deck (card-art grid, deck builder), Draw Rates (with presets), Banners. Reads/writes the same files scooby does, so both stay interchangeable.
- One-click launch: starts the local ARTEMiS server automatically and stops it when the game exits.
- Optional gamescope: windowed or fullscreen, optional AMD FSR upscaling.
- Graphics: render scale up to 200% (supersampling against jagged edges), SMAA, anisotropic filtering, shadow resolution.
- Target FPS 60, or 120 (experimental - uses a one-byte-patched copy of fgohook.dll, the original stays untouched; higher GPU load, menus/touch may misbehave).
- "Live log in a terminal" option: opens your terminal with the game's log in real time (handy when the GUI is started by double-click).
- Self-healing on every launch: GPU compatibility (Mesa driconf entry in `~/.drirc`, missing DLLs), shader cache kept outside the install so reinstalls don't recompile shaders.
- Shader cache can be cleared from Game Settings -> Advanced Graphics.
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

First-time setup:

1. **Setup tab** - set the folders: Install root (the folder holding `App/` and `Server/`), Wine prefix, and the Wine / Proton build. Click **Set up / update** if the Python environment says "not created yet". Optionally point the EN-patch payload folder at the English patch and click **Apply EN Patch**.
2. **Save** - if the folders check out, the other tabs appear right away; if not, an error says what's wrong (fix it, or quit).
3. **Server tab** - set the host and ports. For a remote MariaDB, fill in its host, username, password and database name, then click **Check DB connection**. If the database is empty, **Init DB** unlocks: it imports the newest dump in `linux/backups/` - the bundled `artemis-init.sql` (empty game schema plus the default user), or a newer backup of your own - and asks for a `.sql` file if there is none and greys out again once the game's tables exist. Also set **Daily report time** to an hour you're unlikely to play (for example 02:00): the game can't boot during the hour before it (see the FAQ). Click **Save**.
4. **Ready to play** - adjust Game Settings / Controls if you like, then **Save & Play**. The first launch compiles shaders, so it loads slower once.

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

**Stuck at "ALL.Net : WAIT (A, BUSY)" / "TIME STOP" on the startup screen?**
The game was started within about an hour before its daily billing report time (07:00 by default). Restart it after that time, and move the time to an hour you don't play (Server tab -> Daily report time).

**"SATELLITE:SUB" on the startup screen, Location Server WAIT, or ERROR 8404?**
The game's Startup Mode got saved as Sub Unit. Press F1 for the Game Test Menu (F2 moves, F1 confirms), open Game Settings, set Startup Mode to Main Unit, then Exit and Exit (Reboot).

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

- Cloud23333 - the FGO Arcade distribution this runs, including its compatibility hook (fgohook).
- githubuser420x - FGOAC scooby, the Windows launcher this GUI mirrors (reference for its features and data formats), and the English patch.
- segatools - upstream base of the arcade I/O hooks.

---

### Notes

Built and maintained with the help of AI.
