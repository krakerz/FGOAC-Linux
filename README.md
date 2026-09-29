# FGOAC-Linux

Native Linux/bash replacements for the PowerShell scripts that ship with a
Cloud23333 **FGO Arcade** distribution, so the whole thing (launcher, ARTEMiS
server, English patch) runs under Wine/Proton without PowerShell trying to
use Windows-only subsystems (WMI/CIM, the Service Control Manager, WinForms)
that Wine doesn't implement.

This repo is **only the Linux scripts** (`linux/`). It does not contain the
game itself - `App/`, `Server/`, `DEVICE/`, `AMFS/`, `GameData/`, `compat/`,
the launcher `.exe`s, etc. are Cloud23333's own copyrighted distribution and
are never committed here (see `.gitignore`). You need your own existing FGO
Arcade install; these scripts run alongside it, reading and writing a few of
its config files in place.

## Requirements

- An existing FGO Arcade install (the folder with `App/` and `Server/` in it)
- `wine` (any build; Proton also works) - only needed for `fgo-launcher.sh`
  and for `start-fgo-local-server.sh` if you use the bundled Windows MariaDB
- `python3`
- `curl`, `flock`, `pgrep`/`pkill` (util-linux + procps - present on
  virtually every distro)
- `zenity` (optional, nicer folder picker for `apply-en-patch.sh`)
- `python3-tk`/`tkinter` and `python-Pillow` for `fgo-gui.sh`'s settings
  window (Pillow renders the Deck tab's card artwork); `python-evdev` is
  optional on top of that, for live gamepad-button capture in the same GUI
- A C compiler isn't needed at runtime - `linux/shims/ntquery_shim.dll` ships
  precompiled. Only needed if you modify `linux/shims/ntquery_shim.c` (see
  `linux/shims/README.md`).

## Quick start

```sh
linux/setup.sh --install-root "/path/to/your/FGO Arcade folder" --wineprefix /path/to/wine/prefix
```

This writes `linux/fgo.env` (from `fgo.env.example`) and sets up a Python
venv at `linux/venv` with everything the ARTEMiS server needs (from
`Server/artemis/requirements.txt`, plus `msgpack`, which that file is
missing, plus a `PyMySQL<1.1` pin - newer PyMySQL removed converters
`aiomysql` still imports), pointing `FGO_PYTHON` at it. Re-run it anytime
(e.g. after a `git pull` that changed `requirements.txt`) to top up the
venv - it's idempotent. Omit `--wineprefix` if you only need the server-side
scripts and not `fgo-launcher.sh`. See `linux/fgo.env.example` for every
variable. Once that's done:

```sh
./fgo-gui.sh                      # a native settings window: Setup, Display, Controls, Server, Account, Deck, + Play
```

or, script-by-script instead of the GUI:

```sh
linux/fix-server-config.sh        # syncs core.yaml/fgo-launcher.json ports+database - fixes a fresh/regenerated install's stale defaults; also runs automatically at the end of setup.sh if the install is already there
linux/apply-en-patch.sh           # applies the English text patch, if you have the payload for it (needs FGO_PACKAGE_ROOT if the package isn't next to this repo - see Configuration)
linux/start-fgo-local-server.sh   # ARTEMiS (ALL.Net/billing/AimeDB), if you're running your own server - fgo-launcher.sh normally starts this itself
linux/fgo-launcher.sh             # launches the game itself
```

`fgo-gui.sh` (project root - the obvious first thing to run) is a Linux-native alternative to `scooby.exe`'s own GUI, covering everything except the English patch itself:
- **Setup** - install root, Wine prefix, Proton/wine build (auto-discovered from your Steam compat-tools folders), Python venv (runs `setup.sh` for you), and the EN-patch payload folder. Always available, even before anything else is configured.
- **Display / Controls / Server** - resolution, display mode, target FPS, keyboard/controller mapping (with live "press a button" capture), and the same server/database settings `fix-server-config.sh` manages.
- **Account** - create/switch/delete/reset/repair accounts, the same "One-Click Inventory and Growth" shortcuts scooby's own Play tab has (grant all servants/CEs, max bond, clear quests, etc.), a Grant Items dialog, and a print-history viewer - all via the game's own `Server/tools/fgo_account.py` (run with our native Python, no Wine needed for this part).
- **Deck** - a card-art grid (Pillow-rendered thumbnails, paginated, searchable), with English card names and Craft Essence effect text read live from a local `scooby` source checkout (`FGO_SCOOBY_SRC`, optional - not bundled here, see Configuration), and a double-click dialog for picking quantities across a card's different art variants - for building `App/deck.json`. Account/card data is always loaded live from `fgo_account.py`'s own output - nothing about specific cards is hardcoded. Without `FGO_SCOOBY_SRC`, names just show untranslated.
- **Save && Play** - saves everything, then launches via `fgo-launcher.sh`.

Not covered (use `scooby.exe` itself for these): photo mode, banners, and draw-rate/gacha-weight tuning.

It reads/writes the exact same files `scooby.exe` does, so the two stay interchangeable. `scooby.exe` itself (a separate .NET app, run through your `wine`/Proton build directly, e.g. `"$FGO_WINE" "/path/to/FGOAC scooby.exe"`) is still worth keeping around for photo mode, banners, and anything else `fgo-gui.sh` doesn't cover.

A typical "fresh install" cycle: `setup.sh` (runs `fix-server-config.sh` itself if the install's already there) → run `FGOAC scooby.exe` once to create/manage an account, quit it → `fgo-launcher.sh` to actually play. `fgo-launcher.sh` also keeps the compiled shader cache outside the install (`FGO_SHADER_CACHE_DIR` in `fgo.env`, default `~/.cache/fgoac-linux/shader-cache`), so repeated fresh installs don't each pay a ~45-90s cold shader recompile.

## Configuration

Two different kinds of config are in play: **this repo's own** (`linux/fgo.env`,
tracked as an example only) and **the game install's own** files, which live
in your FGO Arcade folder, not in this repo, and existed before you added
these scripts. The scripts read and sometimes write the game install's files
directly - they don't duplicate that config into `linux/`.

### `linux/fgo.env` (this repo)

Copy `linux/fgo.env.example` to `linux/fgo.env` (or let `setup.sh` do it) and
fill in:

| Variable | Meaning |
|---|---|
| `FGO_INSTALL_ROOT` | Path to the folder holding `App/` and `Server/`. |
| `WINEPREFIX` | The Wine prefix this install runs in. |
| `FGO_WINE` | Wine binary to invoke (default `wine` on `PATH`). Must be a plain wine-compatible binary, not a launcher-wrapper CLI (see the comment in `fgo.env.example`). |
| `FGO_PYTHON` | Python interpreter for the scripts and the ARTEMiS server. `setup.sh` points this at its own venv automatically. |
| `FGO_PACKAGE_ROOT` | Folder holding `manifest.json`/`payload/` for `apply-en-patch.sh`. Defaults to this project's own parent folder; set it if you keep the patch package elsewhere (e.g. a separate downloaded release folder). |
| `FGO_SERVER_HTTP_PORT` / `_BILLING_PORT` / `_AIME_PORT` / `_DB_PORT` | Ports `fix-server-config.sh` applies. Defaults already match this project's own values below - only set these if yours genuinely differ. |
| `FGO_SCOOBY_SRC` | Optional path to a local `scooby` launcher source checkout. Lets the Deck tab show English card names/Craft Essence effect text, read live from its `src/FGOLocalPlatform.*.json`; not required, and this data is never bundled in this repo. |

### `App/fgo-launcher.json` (your game install, not this repo)

The game's own launcher settings file. Fields `fgo-launcher.sh` actually
reads:

| Field | Meaning |
|---|---|
| `serverHost` | `"auto"`/`"local"`/`127.0.0.1`/`192.168.100.1` all mean "run/use the local server"; anything else is treated as a remote server address. |
| `requiredPorts` | Ports `fgo-launcher.sh` checks are open before launching. **Must match `serverPorts` below and `core.yaml`** - if you remap a port in one, remap it everywhere, or you'll get `not reachable on required port(s): ...`. `fix-server-config.sh` does this consistently in one step. |
| `serverPorts.http` / `.billing` / `.aime` | ALL.Net/billing/AimeDB ports. Linux won't let an unprivileged process bind ports below 1024, hence `http` defaults to `8777` (not the distribution's original `777`) everywhere these scripts touch it. |
| `chineseEnabled` | Despite the name, this is really "use `App/zh` for text" - it's the switch `apply-en-patch.sh` turns on, since the English patch replaces the contents of `App/zh` rather than adding a new folder. |
| `displayMode`, `resolutionWidth/Height`, `windowed`, `monitorDevice` | Passed straight through to the game/`fgohook`. |
| `autoStartLocalServer` | Whether `fgo-launcher.sh` starts `start-fgo-local-server.sh` itself before launching. |

### `Server/artemis/config/core.yaml` (your game install, not this repo)

The ARTEMiS server's own config. The field that matters most for
`start-fgo-local-server.sh`:

| Field | Meaning |
|---|---|
| `database.host` | `127.0.0.1`/`localhost` makes the script start a MariaDB itself (native `mariadbd`/`mysqld` if on `PATH`, else the bundled Windows one via wine, using `Server/mariadb.ini`). Any other host is assumed already running and is only checked for reachability. |
| `database.username`/`.password`/`.name`/`.port` | Standard MySQL/MariaDB connection info. `fix-server-config.sh` only manages `.port`; the rest you set by hand once. A wrong `.port` here is also why `FGOAC scooby.exe`'s own account-management GUI can fail with `WinError 10061` (connection refused) - it shells out to `Server/tools/fgo_account.py`, which reads this same file. |
| `database.ssl_enabled` | Set `false` if your MariaDB has no TLS certificate configured (true for the bundled local one) - some Linux MariaDB clients/drivers default to requiring TLS, which a plain bundled server doesn't offer. |

### `Server/mariadb.ini` (your game install, not this repo)

Only relevant if you run the bundled local MariaDB (`database.host` above is
local). Sets `datadir`, `port`, `bind-address` for `mariadbd`. Not touched by
these scripts.

### GPU compatibility (non-NVIDIA cards)

`ago.exe` calls NVIDIA-only OpenGL bindless-buffer extensions unconditionally.
On AMD/Intel (Mesa) GPUs this needs the distribution's own compat layer:
copy `compat/fgoglcompat.dll` (the "Legacy" layer - not `compat/amd-shim/`,
which does not cover this) to `App/fgoglcompat.dll`; `fgo-launcher.sh`
already injects it automatically via `-k` if present. Cards with native
`GL_ARB_bindless_texture` support (check with `glxinfo | grep bindless`)
also need a Mesa driconf override, since `ago.exe` hits a GLSL compile error
Mesa rejects by default - `fgo-launcher.sh` self-heals this automatically on
every launch (`linux/tools/ensure_drirc.py`): it adds the stanza below to
`~/.drirc` if it's missing, parsing any existing file first so other games'
own driconf entries are never touched or overwritten; a file that isn't
recognizable driconf XML is left alone entirely rather than guessed at.

```xml
<!-- ~/.drirc -->
<?xml version="1.0"?>
<driconf>
    <device>
        <application name="FGO Arcade" executable="ago.exe">
            <option name="allow_glsl_embedded_structure_declarations" value="true" />
        </application>
    </device>
</driconf>
```

Purge `App/shader-cache-r10/` once after this is added if the cache already
has entries from before.

## Script map

Original-PowerShell-to-bash mapping, for the pieces not already covered
above:

| Original | Here | Notes |
|---|---|---|
| `Apply-EN-Patch.ps1` | `linux/apply-en-patch.sh` (+ `tools/apply_patch_files.py`) | Runs directly on the filesystem, no wine needed. Accepts a bare `payload/` folder alone (no `manifest.json`), falling back to hashing the source files instead of verifying against a published checksum. |
| `FGO_EnvironmentCheck.ps1` | `linux/fgo-environment-check.sh` | DLL checks are file-existence, not `LoadLibrary`. |
| `FGO_StartupChecks.ps1` | `linux/fgo-startup-checks.sh` | Sourced library, just `fgo_writable_layout`. |
| `FGO_Launcher.ps1` | `linux/fgo-launcher.sh` (+ `tools/read_launcher_config.py`, `tools/segatools_ini.py`) | See caveats below. |
| `Server/Start-FGOLocalServer.ps1` | `linux/start-fgo-local-server.sh` (+ `tools/set_core_hostname.py`) | Reuses `Server/tools/fgo_server_config.py` (part of the game distribution itself) instead of guessing `ServerSettings.ps1`'s logic. Starts ARTEMiS with native `python3`, not the bundled Windows one. |
| `Server/Stop-FGOLocalServer.ps1` | `linux/stop-fgo-local-server.sh` | Fresh script, PID-file based - not a port. |
| `Server/Stop-FGOLocalServerWhenIdle.ps1` | `linux/stop-fgo-local-server-when-idle.sh` | Waits on real PIDs instead of re-discovering processes by name via WMI. |
| *(none - new)* | `linux/fix-server-config.sh` | Thin wrapper around `Server/tools/fgo_server_config.py apply` - fixes a fresh/regenerated install's stale port/database config (e.g. scooby's account GUI failing with `WinError 10061` because `core.yaml`'s database port doesn't match the real server). Runs automatically at the end of `setup.sh` if the install is already in place. |
| *(none - new)* | `fgo-gui.sh` (project root) + `linux/tools/fgo_gui.py`, `linux/tools/fgo_env.py` | The Linux-native settings GUI described above. |
| *(none - new)* | `linux/shims/ntquery_shim.dll`, `linux/shims/feedback_shim.dll` | Compatibility fixes, not ports - see `linux/shims/README.md`. |

## Known caveats (behavioral differences from the original scripts)

- **Remote MariaDB**: `start-fgo-local-server.sh` reads `database.host` from
  `core.yaml`. `127.0.0.1`/`localhost` starts a MariaDB itself (native
  `mariadbd`/`mysqld` if on `PATH`, else the bundled Windows one via wine);
  any other host is treated as already-running and only checked for
  reachability. Point `database.host` at your real remote address, or
  tunnel/port-forward `127.0.0.1:<port>` to it.
- **Local MariaDB shutdown**: the original sends a clean `mariadb-admin
  shutdown` using a hardcoded root password from the base install.
  `stop-fgo-local-server.sh` sends `SIGTERM` to the process group instead -
  avoids baking a live credential into a new script file.
- **GPU preference**: there's no Linux equivalent to the original's per-exe
  `HKCU\...\UserGpuPreferences` registry value, so `fgo-launcher.sh` sets
  `DRI_PRIME=1` and the NVIDIA PRIME env vars instead when
  `preferHighPerformanceGpu` is on.
- **Borderless mode**: the original's `__COMPAT_LAYER=DISABLEDXMAXIMIZEDWINDOWEDMODE`
  is a real Windows AppCompat shim Wine doesn't implement; passed through as
  a no-op for parity, so borderless behavior under Wine may not match Windows.
- **Locale Remulator env vars** (`LRCodePage` etc.): these carry a single
  Unicode code point, not a decimal string. Set here as the UTF-8 encoding of
  that code point, relying on Wine re-encoding a child process's Unix
  environment into UTF-16 - not yet confirmed against a running
  `LRHookx64.dll`.
- **Process cleanup**: no WMI here - PIDs are tracked directly for processes
  these scripts start themselves (`game.pid`, `artemis.pid`, `mariadb.pid`),
  plus a best-effort `pgrep -af` path match for leftovers from a previous run.
- **`zh/fgozh.dll` failing to load under Wine** (`DLL failed to load inside
  target process`, exit code 1 within seconds): caused by Wine's `ntdll.dll`
  not implementing `NtQueryInformationByName`, which this DLL's `DllMain`
  treats as fatal. Fixed by `linux/shims/ntquery_shim.dll`, auto-injected by
  `fgo-launcher.sh` as the first `-k` argument if present - see
  `linux/shims/README.md`. Confirmed on Wine 11.17 and CachyOS's
  wine-10.0-20260425.

## Current status

The launcher, ARTEMiS server, English patch application, and account
management (via the distribution's own `FGOAC scooby.exe` GUI) all run
end-to-end under Wine/Proton, and `ago.exe` itself reaches a stable,
crash-free running state (confirmed: shaders compile, audio plays, the
title screen loads) once the GPU compatibility steps above are done. The
one known remaining issue is the game's own window occasionally not
becoming visible on-screen right after launch (an intermittent Wine/window-
manager focus race, not a crash - the game keeps running fine underneath;
just relaunch if this happens) - see the project's own NOTES.md for the
full investigation.
