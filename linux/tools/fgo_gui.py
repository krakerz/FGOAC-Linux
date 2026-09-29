"""Standalone settings + launcher GUI for an FGO Arcade install - a Linux-
native alternative to running FGOAC scooby.exe under Wine for everything
except its own full card-art deck browser. Covers: first-time environment
setup (install root, Wine prefix, Proton/wine build, Python venv, EN-patch
payload location), Display, Controls, Server, Account management, and a
Deck editor - plus a Play button. Never touches App/zh directly - the
English patch itself is still applied via apply-en-patch.sh.

Reads/writes the exact same files scooby.exe does (linux/fgo.env for this
project's own config; App/fgo-launcher.json, App/segatools.ini, App/deck.json,
Server/artemis/config/core.yaml via the game's own Server/tools/fgo_server_config.py
and fgo_account.py), so scooby.exe and this tool stay interchangeable - either
one can be used and the other will see the change. Deck/account data is
always read live from fgo_account.py's own output, never hardcoded here.

Usage: fgo_gui.py (reads FGO_INSTALL_ROOT etc. from the environment - see
fgo-gui.sh, which sources fgo.env first). Works even with no install
configured yet - the Setup tab is always available; the others show a
placeholder until a valid install root is set.
"""
import json
import os
import subprocess
import sys
import tkinter as tk
from pathlib import Path
from tkinter import filedialog, messagebox, simpledialog, ttk

sys.path.insert(0, str(Path(__file__).resolve().parent))
from segatools_ini import get_ini_value, set_ini_value  # noqa: E402
from fgo_env import env_file_path, get_env_value, read_env_file, set_env_values  # noqa: E402

try:
    from PIL import Image, ImageTk
    HAVE_PIL = True
except ImportError:
    HAVE_PIL = False

try:
    import evdev
    HAVE_EVDEV = True
except ImportError:
    HAVE_EVDEV = False


# --- XInput button choices (values match segatools.ini's own hex encoding,
# and scooby's ControlSettingsView.cs's PhysicalButtons/Choice tables) ---
XINPUT_CHOICES = [
    ("Disabled", 0x0000),
    ("A", 0x1000), ("B", 0x2000), ("X", 0x4000), ("Y", 0x8000),
    ("A or B", 0x3000), ("X or Y", 0xC000),
    ("LB", 0x0100), ("RB", 0x0200), ("LT", 0x10000), ("RT", 0x20000),
    ("Left Stick Click", 0x0040), ("Right Stick Click", 0x0080),
    ("Start", 0x0010), ("Back", 0x0020),
    ("D-Pad Up", 0x0001), ("D-Pad Down", 0x0002),
    ("D-Pad Left", 0x0004), ("D-Pad Right", 0x0008),
]
XINPUT_VALUE_TO_NAME = {v: n for n, v in XINPUT_CHOICES}

# Standard xpad-driver (Xbox-compatible) evdev button codes -> XInput mask.
# Covers the common case (this is what shows up for the vast majority of
# wired/wireless pads once the kernel recognizes them as Xbox-compatible,
# including via Bluetooth/hid-generic on a real Xbox-layout pad) - not a
# full SDL-style per-device remapping database.
EVDEV_BUTTON_TO_XINPUT = {
    evdev.ecodes.BTN_SOUTH if HAVE_EVDEV else 304: 0x1000,   # A
    evdev.ecodes.BTN_EAST if HAVE_EVDEV else 305: 0x2000,    # B
    evdev.ecodes.BTN_NORTH if HAVE_EVDEV else 307: 0x4000,   # X
    evdev.ecodes.BTN_WEST if HAVE_EVDEV else 308: 0x8000,    # Y
    evdev.ecodes.BTN_TL if HAVE_EVDEV else 310: 0x0100,      # LB
    evdev.ecodes.BTN_TR if HAVE_EVDEV else 311: 0x0200,      # RB
    evdev.ecodes.BTN_THUMBL if HAVE_EVDEV else 317: 0x0040,  # Left stick click
    evdev.ecodes.BTN_THUMBR if HAVE_EVDEV else 318: 0x0080,  # Right stick click
    evdev.ecodes.BTN_START if HAVE_EVDEV else 315: 0x0010,   # Start
    evdev.ecodes.BTN_SELECT if HAVE_EVDEV else 314: 0x0020,  # Back
}

# Keyboard choices: (label, Windows virtual-key code). Covers what a game
# control scheme realistically uses - not an exhaustive VK table.
_LETTERS = [(chr(c), c) for c in range(0x41, 0x5B)]  # A-Z
_DIGITS = [(chr(c), c) for c in range(0x30, 0x3A)]   # 0-9
_FKEYS = [(f"F{n}", 0x70 + n - 1) for n in range(1, 13)]
KEY_CHOICES = [
    ("Disabled", 0x00),
    ("Left Mouse Button", 0x01), ("Right Mouse Button", 0x02),
    ("Middle Mouse Button", 0x04), ("Mouse Button 4", 0x05), ("Mouse Button 5", 0x06),
    *_LETTERS, *_DIGITS,
    ("Space", 0x20), ("Enter", 0x0D), ("Tab", 0x09), ("Escape", 0x1B),
    ("Backspace", 0x08),
    ("Left Shift", 0xA0), ("Right Shift", 0xA1),
    ("Left Ctrl", 0xA2), ("Right Ctrl", 0xA3),
    ("Left Alt", 0xA4), ("Right Alt", 0xA5),
    ("Left Arrow", 0x25), ("Up Arrow", 0x26), ("Right Arrow", 0x27), ("Down Arrow", 0x28),
    *_FKEYS,
]
KEY_VALUE_TO_NAME = {v: n for n, v in KEY_CHOICES}

KEYBOARD_ACTIONS = [
    ("Move Up", "up", 0x57), ("Move Down", "down", 0x53),
    ("Move Left", "left", 0x41), ("Move Right", "right", 0x44),
    ("Attack", "attack", 0x02), ("Dash", "dash", 0xA0),
    ("Switch Lock-on", "target", 0x46), ("Noble Phantasm", "np", 0x20),
    ("Center Camera", "camera", 0x43),
    ("Servant Skill 1", "skill1", 0x31), ("Servant Skill 2", "skill2", 0x32),
    ("Servant Skill 3", "skill3", 0x33),
]
XINPUT_ACTIONS = [
    ("Attack", "attack", 0x3000), ("Dash", "dash", 0x10000),
    ("Switch Lock-on", "target", 0x0100), ("Noble Phantasm", "np", 0xC000),
    ("Center Camera", "camera", 0x0040),
    ("Servant Skill 1", "skill1", 0x0000), ("Servant Skill 2", "skill2", 0x0000),
    ("Servant Skill 3", "skill3", 0x0000),
]

DISPLAY_MODES = [("Windowed", "windowed"), ("Borderless", "borderless"), ("Exclusive fullscreen", "exclusive")]


def is_valid_install(path_str):
    if not path_str:
        return False
    path = Path(path_str)
    return (path / "App" / "fgo-launcher.json").is_file() and (path / "Server").is_dir()


def install_root_or_none():
    root = os.environ.get("FGO_INSTALL_ROOT", "")
    return Path(root) if is_valid_install(root) else None


def install_root():
    root = install_root_or_none()
    if root is None:
        raise SystemExit("FGO_INSTALL_ROOT is not set to a valid install - configure it in the Setup tab first.")
    return root


# --- Wine/Proton build discovery, for the Setup tab's dropdown ---
WINE_SEARCH_DIRS = [
    "~/.steam/steam/compatibilitytools.d",
    "~/.local/share/Steam/compatibilitytools.d",
]


def discover_wine_builds():
    """Returns [(label, wine_binary_path), ...] - "wine (system PATH)" first,
    then every Proton/compat-tool build found under the usual Steam
    locations that actually has a files/bin/wine binary."""
    builds = [("wine (system PATH)", "wine")]
    seen = set()
    for search_dir in WINE_SEARCH_DIRS:
        base = Path(search_dir).expanduser()
        if not base.is_dir():
            continue
        for entry in sorted(base.iterdir()):
            wine_bin = entry / "files" / "bin" / "wine"
            if not wine_bin.is_file():
                continue
            resolved = str(wine_bin.resolve())
            if resolved in seen:
                continue
            seen.add(resolved)
            builds.append((entry.name, str(wine_bin)))
    return builds


def launcher_json_path():
    return install_root() / "App" / "fgo-launcher.json"


def segatools_ini_path():
    return install_root() / "App" / "segatools.ini"


def server_tool_path():
    return install_root() / "Server" / "tools" / "fgo_server_config.py"


def set_core_database_path():
    return Path(__file__).resolve().parent / "set_core_database.py"


def fgo_python():
    return os.environ.get("FGO_PYTHON") or sys.executable


def load_launcher_json():
    path = launcher_json_path()
    return json.loads(path.read_text(encoding="utf-8"))


def save_launcher_json(config):
    path = launcher_json_path()
    path.write_text(json.dumps(config, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def run_server_tool(*args):
    result = subprocess.run(
        [fgo_python(), str(server_tool_path()), *args],
        capture_output=True, text=True, timeout=15,
    )
    data = json.loads(result.stdout) if result.stdout.strip() else {}
    if result.returncode != 0:
        raise RuntimeError(data.get("error") or result.stderr or "fgo_server_config.py failed")
    return data


def account_tool_path():
    return install_root() / "Server" / "tools" / "fgo_account.py"


def deck_json_path():
    return install_root() / "App" / "deck.json"


def run_account_tool(*args, timeout=30):
    """Runs fgo_account.py with our own native FGO_PYTHON (the ARTEMiS venv -
    this script imports artemis's own core/titles modules, same as when the
    real server runs) rather than the game's bundled Windows python.exe under
    Wine - confirmed working identically, no Wine round-trip needed."""
    result = subprocess.run(
        [fgo_python(), str(account_tool_path()), *args, "--json"],
        capture_output=True, text=True, timeout=timeout,
        cwd=str(install_root() / "Server"),
    )
    data = json.loads(result.stdout) if result.stdout.strip() else {}
    if result.returncode != 0 or not data.get("ok", True):
        raise RuntimeError(data.get("error") or result.stderr.strip() or "fgo_account.py failed")
    return data


DATA_DIR = Path(__file__).resolve().parent / "data"


class CardTranslations:
    """English name/effect lookup, from the same static reference data
    scooby.exe itself ships (FGOLocalPlatform.CardNames.json/CraftEffects.json)
    - not derived from this account's own data, so it's independent of which
    cards you actually own.

    This data isn't ours to redistribute (scooby ships no LICENSE granting
    that), so it's never bundled in this repo - found dynamically instead,
    checked in order: FGO_SCOOBY_SRC in fgo.env (a scooby source checkout -
    its src/FGOLocalPlatform.*.json), then linux/tools/data/ (for anyone who
    drops a copy there themselves - gitignored, not tracked). Missing
    entirely just means untranslated (Japanese) names/no effect text - never
    a hard error."""

    FILENAMES = {"names": "FGOLocalPlatform.CardNames.json", "effects": "FGOLocalPlatform.CraftEffects.json"}

    def __init__(self):
        self.names = self._load("names", "CardNames.json")
        self.effects = self._load("effects", "CraftEffects.json")

    def _candidates(self, scooby_filename, local_filename):
        scooby_src = os.environ.get("FGO_SCOOBY_SRC", "").strip()
        if scooby_src:
            yield Path(scooby_src).expanduser() / "src" / scooby_filename
        yield DATA_DIR / local_filename

    def _load(self, key, local_filename):
        for candidate in self._candidates(self.FILENAMES[key], local_filename):
            try:
                return json.loads(candidate.read_text(encoding="utf-8"))
            except (OSError, json.JSONDecodeError):
                continue
        return {}

    @staticmethod
    def internal_id(card):
        if card.get("craft_essence_id"):
            return f"CE{card['craft_essence_id']:05d}"
        if card.get("servant_id"):
            return f"SVT{card['servant_id']:05d}"
        return None

    def english_name(self, card):
        internal_id = self.internal_id(card)
        entry = self.names.get(internal_id) if internal_id else None
        return entry["Chinese"] if entry else None  # yes, "Chinese" key really holds the English name upstream

    def japanese_name(self, card):
        internal_id = self.internal_id(card)
        entry = self.names.get(internal_id) if internal_id else None
        return entry["Japanese"] if entry else None

    def craft_essence_effect(self, card):
        internal_id = self.internal_id(card)
        if not internal_id or not internal_id.startswith("CE"):
            return None
        return self.effects.get(internal_id)


TRANSLATIONS = CardTranslations()


class CaptureDialog(tk.Toplevel):
    """Modal 'press a button' dialog for XInput live capture via evdev."""

    def __init__(self, parent):
        super().__init__(parent)
        self.title("Press a button")
        self.result = None
        self.geometry("360x120")
        self.resizable(False, False)
        tk.Label(self, text="Press the controller button you want to assign...\n(Esc to cancel)",
                  justify="center").pack(expand=True, fill="both", padx=16, pady=16)
        self.protocol("WM_DELETE_WINDOW", self.destroy)
        self.bind("<Escape>", lambda e: self.destroy())
        self.transient(parent)
        self.grab_set()
        self.after(50, self._poll)

    def _devices(self):
        found = []
        for path in evdev.list_devices():
            try:
                dev = evdev.InputDevice(path)
            except OSError:
                continue
            caps = dev.capabilities().get(evdev.ecodes.EV_KEY, [])
            if any(code in EVDEV_BUTTON_TO_XINPUT for code in caps):
                found.append(dev)
        return found

    def _poll(self):
        if not self.winfo_exists():
            return
        for dev in self._devices():
            try:
                event = dev.read_one()
            except (OSError, BlockingIOError):
                event = None
            while event is not None:
                if event.type == evdev.ecodes.EV_KEY and event.value == 1:
                    mask = EVDEV_BUTTON_TO_XINPUT.get(event.code)
                    if mask is not None:
                        self.result = mask
                        self.destroy()
                        return
                try:
                    event = dev.read_one()
                except (OSError, BlockingIOError):
                    event = None
        self.after(30, self._poll)


class SetupTab(ttk.Frame):
    """Always available, even with no install configured yet - edits
    linux/fgo.env directly (the same file setup.sh writes), so this is a
    GUI front-end for what setup.sh already does via flags, plus the wine
    build picker and EN-patch payload location."""

    def __init__(self, parent, on_saved=None):
        super().__init__(parent, padding=16)
        self.on_saved = on_saved
        env_text = read_env_file()

        row = 0
        ttk.Label(self, text="Install root (holds App/ and Server/):").grid(row=row, column=0, columnspan=3, sticky="w")
        row += 1
        self.install_root_var = tk.StringVar(value=get_env_value(env_text, "FGO_INSTALL_ROOT"))
        ttk.Entry(self, textvariable=self.install_root_var, width=50).grid(row=row, column=0, columnspan=2, sticky="we")
        ttk.Button(self, text="Browse...", command=lambda: self._browse_dir(self.install_root_var)).grid(row=row, column=2, sticky="w", padx=(6, 0))
        row += 1

        ttk.Label(self, text="Wine prefix:").grid(row=row, column=0, columnspan=3, sticky="w", pady=(12, 0))
        row += 1
        self.wineprefix_var = tk.StringVar(value=get_env_value(env_text, "WINEPREFIX"))
        ttk.Entry(self, textvariable=self.wineprefix_var, width=50).grid(row=row, column=0, columnspan=2, sticky="we")
        ttk.Button(self, text="Browse...", command=lambda: self._browse_dir(self.wineprefix_var)).grid(row=row, column=2, sticky="w", padx=(6, 0))
        row += 1

        ttk.Label(self, text="Wine / Proton build:").grid(row=row, column=0, columnspan=3, sticky="w", pady=(12, 0))
        row += 1
        current_wine = get_env_value(env_text, "FGO_WINE", "wine")
        builds = discover_wine_builds()
        labels = [label for label, _ in builds]
        self._wine_by_label = dict(builds)
        self._label_by_wine = {path: label for label, path in builds}
        self.wine_display_var = tk.StringVar(value=self._label_by_wine.get(current_wine, current_wine))
        if self.wine_display_var.get() not in labels:
            labels = labels + [self.wine_display_var.get()]
        self.wine_combo = ttk.Combobox(self, textvariable=self.wine_display_var, values=labels, width=47)
        self.wine_combo.grid(row=row, column=0, columnspan=2, sticky="we")
        ttk.Button(self, text="Browse...", command=self._browse_wine_binary).grid(row=row, column=2, sticky="w", padx=(6, 0))
        row += 1

        ttk.Label(self, text="EN-patch payload folder (needs manifest.json+payload/, or just payload/ alone):").grid(
            row=row, column=0, columnspan=3, sticky="w", pady=(12, 0))
        row += 1
        self.package_root_var = tk.StringVar(value=get_env_value(env_text, "FGO_PACKAGE_ROOT"))
        ttk.Entry(self, textvariable=self.package_root_var, width=50).grid(row=row, column=0, columnspan=2, sticky="we")
        ttk.Button(self, text="Browse...", command=lambda: self._browse_dir(self.package_root_var)).grid(row=row, column=2, sticky="w", padx=(6, 0))
        row += 1

        ttk.Separator(self, orient="horizontal").grid(row=row, column=0, columnspan=3, sticky="ew", pady=12)
        row += 1

        venv_python = str(Path(__file__).resolve().parent.parent / "venv" / "bin" / "python")
        venv_status = "found" if Path(venv_python).is_file() else "not created yet"
        ttk.Label(self, text=f"Python environment (linux/venv): {venv_status}").grid(row=row, column=0, columnspan=2, sticky="w")
        ttk.Button(self, text="Set up / update", command=self._run_setup).grid(row=row, column=2, sticky="w")
        row += 1
        self.setup_status_var = tk.StringVar(value="")
        ttk.Label(self, textvariable=self.setup_status_var, foreground="gray", wraplength=460).grid(
            row=row, column=0, columnspan=3, sticky="w", pady=(4, 0))
        row += 1

        ttk.Separator(self, orient="horizontal").grid(row=row, column=0, columnspan=3, sticky="ew", pady=12)
        row += 1
        ttk.Button(self, text="Save environment settings", command=self.save).grid(row=row, column=0, sticky="w")
        self.status_var = tk.StringVar(value="")
        ttk.Label(self, textvariable=self.status_var, foreground="gray", wraplength=460).grid(
            row=row, column=1, columnspan=2, sticky="w")

    def _browse_dir(self, var):
        chosen = filedialog.askdirectory(initialdir=var.get() or str(Path.home()))
        if chosen:
            var.set(chosen)

    def _browse_wine_binary(self):
        chosen = filedialog.askopenfilename(title="Select a wine binary", initialdir=str(Path.home()))
        if chosen:
            self.wine_display_var.set(chosen)
            if self.wine_combo["values"] and chosen not in self.wine_combo["values"]:
                self.wine_combo["values"] = (*self.wine_combo["values"], chosen)

    def _resolved_wine(self):
        display = self.wine_display_var.get()
        return self._wine_by_label.get(display, display)

    def _run_setup(self):
        script = Path(__file__).resolve().parent.parent / "setup.sh"
        args = [str(script)]
        if self.install_root_var.get().strip():
            args += ["--install-root", self.install_root_var.get().strip()]
        if self.wineprefix_var.get().strip():
            args += ["--wineprefix", self.wineprefix_var.get().strip()]
        wine = self._resolved_wine()
        if wine:
            args += ["--wine", wine]
        self.setup_status_var.set("Running setup.sh...")
        self.update_idletasks()
        try:
            result = subprocess.run(args, capture_output=True, text=True, timeout=300)
            tail = "\n".join((result.stdout + result.stderr).strip().splitlines()[-5:])
            self.setup_status_var.set(tail or "Done.")
        except Exception as exc:
            self.setup_status_var.set(f"Could not run setup.sh: {exc}")

    def save(self):
        set_env_values({
            "FGO_INSTALL_ROOT": self.install_root_var.get().strip() or None,
            "WINEPREFIX": self.wineprefix_var.get().strip() or None,
            "FGO_WINE": self._resolved_wine() or None,
            "FGO_PACKAGE_ROOT": self.package_root_var.get().strip() or None,
        })
        self.status_var.set(f"Saved to {env_file_path()}. Restart this app for a new install root to take effect.")
        if self.on_saved:
            self.on_saved()


class DisplayTab(ttk.Frame):
    def __init__(self, parent):
        super().__init__(parent, padding=16)
        self.config_data = load_launcher_json()

        row = 0
        ttk.Label(self, text="Resolution:").grid(row=row, column=0, sticky="w", pady=4)
        self.width_var = tk.StringVar(value=str(self.config_data.get("resolutionWidth", 1280)))
        self.height_var = tk.StringVar(value=str(self.config_data.get("resolutionHeight", 720)))
        ttk.Entry(self, textvariable=self.width_var, width=8).grid(row=row, column=1, sticky="w")
        ttk.Label(self, text="x").grid(row=row, column=2)
        ttk.Entry(self, textvariable=self.height_var, width=8).grid(row=row, column=3, sticky="w")
        row += 1

        ttk.Label(self, text="Display mode:").grid(row=row, column=0, sticky="w", pady=4)
        self.mode_var = tk.StringVar(value=self.config_data.get("displayMode", "windowed"))
        mode_names = [n for n, _ in DISPLAY_MODES]
        mode_by_name = dict(DISPLAY_MODES)
        name_by_mode = {v: n for n, v in DISPLAY_MODES}
        self.mode_display = tk.StringVar(value=name_by_mode.get(self.mode_var.get(), mode_names[0]))
        combo = ttk.Combobox(self, textvariable=self.mode_display, values=mode_names, state="readonly", width=20)
        combo.grid(row=row, column=1, columnspan=3, sticky="w")
        self._mode_by_name = mode_by_name
        row += 1

        ttk.Label(self, text="Target FPS:").grid(row=row, column=0, sticky="w", pady=4)
        self.fps_var = tk.StringVar(value=str(self.config_data.get("targetFps", 60)))
        ttk.Entry(self, textvariable=self.fps_var, width=8).grid(row=row, column=1, sticky="w")
        row += 1

        ttk.Label(self, text="Monitor device:").grid(row=row, column=0, sticky="w", pady=4)
        self.monitor_var = tk.StringVar(value=self.config_data.get("monitorDevice", r"\\.\DISPLAY1"))
        ttk.Entry(self, textvariable=self.monitor_var, width=20).grid(row=row, column=1, columnspan=3, sticky="w")
        row += 1
        ttk.Label(self, text=r'Windows-style device name (e.g. \\.\DISPLAY1) - the game reports these itself in its logs.',
                  foreground="gray").grid(row=row, column=0, columnspan=4, sticky="w")
        row += 1

        self.gamescope_var = tk.BooleanVar(value=False)
        ttk.Checkbutton(self, text="Run inside gamescope (experimental - known to exit early on this game)",
                        variable=self.gamescope_var).grid(row=row, column=0, columnspan=4, sticky="w", pady=(16, 0))
        row += 1
        self.gamescope_fullscreen_var = tk.BooleanVar(value=False)
        ttk.Checkbutton(self, text="Fullscreen (gamescope only)",
                        variable=self.gamescope_fullscreen_var).grid(row=row, column=0, columnspan=4, sticky="w")

    def validate(self):
        try:
            width = int(self.width_var.get())
            height = int(self.height_var.get())
            fps = int(self.fps_var.get())
        except ValueError:
            raise ValueError("Resolution and target FPS must be whole numbers.")
        if not (480 <= width <= 7680) or not (480 <= height <= 7680):
            raise ValueError("Resolution must be between 480 and 7680 on each side.")
        if not (1 <= fps <= 360):
            raise ValueError("Target FPS must be between 1 and 360.")
        return width, height, fps

    def save(self):
        width, height, fps = self.validate()
        self.config_data["resolutionWidth"] = width
        self.config_data["resolutionHeight"] = height
        self.config_data["targetFps"] = fps
        mode = self._mode_by_name[self.mode_display.get()]
        self.config_data["displayMode"] = mode
        self.config_data["windowed"] = mode != "exclusive"
        self.config_data["monitorDevice"] = self.monitor_var.get()
        save_launcher_json(self.config_data)

    def play_env(self):
        env = {}
        if self.gamescope_var.get():
            env["FGO_GAMESCOPE"] = "1"
            if self.gamescope_fullscreen_var.get():
                env["FGO_GAMESCOPE_FULLSCREEN"] = "1"
        return env


class ControlsTab(ttk.Frame):
    def __init__(self, parent):
        super().__init__(parent, padding=16)
        self.ini_text = segatools_ini_path().read_text(encoding="utf-8")
        self.pending_writes = []  # (section, key, value_str)
        self.keyboard_vars = {}
        self.xinput_vars = {}

        notebook = ttk.Notebook(self)
        notebook.pack(fill="both", expand=True)
        kb_frame = ttk.Frame(notebook, padding=12)
        xi_frame = ttk.Frame(notebook, padding=12)
        notebook.add(kb_frame, text="Keyboard")
        notebook.add(xi_frame, text="Controller (XInput)")

        for row, (label, key, default) in enumerate(KEYBOARD_ACTIONS):
            current = int(get_ini_value(self.ini_text, "keyboard", key, hex(default)), 16)
            var = tk.StringVar(value=KEY_VALUE_TO_NAME.get(current, f"0x{current:X}"))
            ttk.Label(kb_frame, text=label, width=20).grid(row=row, column=0, sticky="w", pady=3)
            names = [n for n, _ in KEY_CHOICES]
            if var.get() not in names:
                names = names + [var.get()]
            ttk.Combobox(kb_frame, textvariable=var, values=names, state="readonly", width=22).grid(row=row, column=1, sticky="w")
            self.keyboard_vars[key] = var

        row = 0
        ttk.Label(xi_frame, text="Controller number:", width=20).grid(row=row, column=0, sticky="w", pady=3)
        self.controller_index_var = tk.StringVar(value=get_ini_value(self.ini_text, "xinput", "controllerIndex", "0"))
        ttk.Combobox(xi_frame, textvariable=self.controller_index_var, values=["0", "1", "2", "3"],
                     state="readonly", width=6).grid(row=row, column=1, sticky="w")
        row += 1
        ttk.Label(xi_frame, text="Stick deadzone:", width=20).grid(row=row, column=0, sticky="w", pady=3)
        self.deadzone_var = tk.StringVar(value=get_ini_value(self.ini_text, "xinput", "stickDeadzone", "7849"))
        ttk.Entry(xi_frame, textvariable=self.deadzone_var, width=10).grid(row=row, column=1, sticky="w")
        row += 1
        ttk.Label(xi_frame, text="(0-32766, default 7849)", foreground="gray").grid(row=row, column=1, sticky="w")
        row += 1
        self.rumble_var = tk.BooleanVar(value=get_ini_value(self.ini_text, "xinput", "rumble", "0") == "1")
        ttk.Checkbutton(xi_frame, text="Rumble enabled", variable=self.rumble_var).grid(row=row, column=0, columnspan=2, sticky="w", pady=(8, 3))
        row += 1
        ttk.Label(xi_frame, text="Rumble strength %:", width=20).grid(row=row, column=0, sticky="w", pady=3)
        self.rumble_strength_var = tk.StringVar(value=get_ini_value(self.ini_text, "xinput", "rumbleStrength", "70"))
        ttk.Entry(xi_frame, textvariable=self.rumble_strength_var, width=10).grid(row=row, column=1, sticky="w")
        row += 2

        ttk.Separator(xi_frame, orient="horizontal").grid(row=row, column=0, columnspan=3, sticky="ew", pady=8)
        row += 1

        if not HAVE_EVDEV:
            ttk.Label(xi_frame, text="python3-evdev not found - live 'press a button' capture is unavailable; use the dropdowns instead.",
                      foreground="gray").grid(row=row, column=0, columnspan=3, sticky="w")
            row += 1

        for label, key, default in XINPUT_ACTIONS:
            current = int(get_ini_value(self.ini_text, "xinput", key, hex(default)), 16)
            var = tk.StringVar(value=XINPUT_VALUE_TO_NAME.get(current, f"0x{current:X}"))
            ttk.Label(xi_frame, text=label, width=20).grid(row=row, column=0, sticky="w", pady=3)
            names = [n for n, _ in XINPUT_CHOICES]
            if var.get() not in names:
                names = names + [var.get()]
            combo = ttk.Combobox(xi_frame, textvariable=var, values=names, state="readonly", width=18)
            combo.grid(row=row, column=1, sticky="w")
            self.xinput_vars[key] = var
            if HAVE_EVDEV:
                ttk.Button(xi_frame, text="Capture...", width=10,
                           command=lambda v=var: self._capture(v)).grid(row=row, column=2, sticky="w", padx=(6, 0))
            row += 1

    def _capture(self, var):
        dialog = CaptureDialog(self.winfo_toplevel())
        self.wait_window(dialog)
        if dialog.result is not None:
            var.set(XINPUT_VALUE_TO_NAME.get(dialog.result, f"0x{dialog.result:X}"))

    def validate(self):
        try:
            deadzone = int(self.deadzone_var.get())
            rumble_strength = int(self.rumble_strength_var.get())
        except ValueError:
            raise ValueError("Deadzone and rumble strength must be whole numbers.")
        if not (0 <= deadzone <= 32766):
            raise ValueError("Stick deadzone must be between 0 and 32766.")
        if not (0 <= rumble_strength <= 100):
            raise ValueError("Rumble strength must be between 0 and 100.")
        return deadzone, rumble_strength

    def save(self):
        deadzone, rumble_strength = self.validate()
        key_name_to_value = {n: v for n, v in KEY_CHOICES}
        xinput_name_to_value = {n: v for n, v in XINPUT_CHOICES}

        def resolve(mapping, name):
            if name in mapping:
                return mapping[name]
            return int(name, 16)  # a "0x..." fallback label from an unrecognized existing value

        text = self.ini_text
        for _, key, _ in KEYBOARD_ACTIONS:
            value = resolve(key_name_to_value, self.keyboard_vars[key].get())
            text = set_ini_value(text, "keyboard", key, f"0x{value:X}")
        for _, key, _ in XINPUT_ACTIONS:
            value = resolve(xinput_name_to_value, self.xinput_vars[key].get())
            text = set_ini_value(text, "xinput", key, f"0x{value:X}")
        text = set_ini_value(text, "xinput", "controllerIndex", self.controller_index_var.get())
        text = set_ini_value(text, "xinput", "stickDeadzone", str(deadzone))
        text = set_ini_value(text, "xinput", "rumble", "1" if self.rumble_var.get() else "0")
        text = set_ini_value(text, "xinput", "rumbleStrength", str(rumble_strength))
        segatools_ini_path().write_text(text, encoding="utf-8")
        self.ini_text = text


class ServerTab(ttk.Frame):
    def __init__(self, parent):
        super().__init__(parent, padding=16)
        self.status_var = tk.StringVar(value="")

        try:
            current = run_server_tool("show")
        except Exception as exc:
            current = {"host": "auto", "http": 8777, "billing": 9999, "aime": 7777, "database": 3306}
            self.status_var.set(f"Could not read current server config: {exc}")

        fields = [
            ("Host (auto/local/<remote IP>)", "host_var", str(current.get("host", "auto"))),
            ("ALL.Net / game port", "http_var", str(current.get("http", 8777))),
            ("Billing port", "billing_var", str(current.get("billing", 9999))),
            ("Aime card-reader port", "aime_var", str(current.get("aime", 7777))),
            ("Database port", "database_var", str(current.get("database", 3306))),
        ]
        row = 0
        for label, attr, default in fields:
            var = tk.StringVar(value=default)
            setattr(self, attr, var)
            ttk.Label(self, text=label, width=26).grid(row=row, column=0, sticky="w", pady=4)
            ttk.Entry(self, textvariable=var, width=22).grid(row=row, column=1, sticky="w")
            row += 1

        ttk.Separator(self, orient="horizontal").grid(row=row, column=0, columnspan=2, sticky="ew", pady=10)
        row += 1
        ttk.Label(self, text="Database connection (optional - leave blank to keep as-is):", foreground="gray").grid(
            row=row, column=0, columnspan=2, sticky="w")
        row += 1
        for label, attr in [("MariaDB host", "db_host_var"), ("MariaDB username", "db_user_var"),
                             ("MariaDB password", "db_password_var"), ("Database name", "db_name_var")]:
            var = tk.StringVar(value="")
            setattr(self, attr, var)
            ttk.Label(self, text=label, width=26).grid(row=row, column=0, sticky="w", pady=4)
            show = "*" if "password" in attr else ""
            ttk.Entry(self, textvariable=var, width=22, show=show).grid(row=row, column=1, sticky="w")
            row += 1

        row += 1
        ttk.Label(self, textvariable=self.status_var, foreground="gray", wraplength=420).grid(
            row=row, column=0, columnspan=2, sticky="w", pady=(8, 0))

    def save(self):
        ports = {}
        for key, var in (("http", self.http_var), ("billing", self.billing_var),
                          ("aime", self.aime_var), ("database", self.database_var)):
            try:
                ports[key] = int(var.get())
            except ValueError:
                raise ValueError(f"{key} port must be a whole number.")
        run_server_tool("apply", "--host", self.host_var.get().strip(),
                         "--http", str(ports["http"]), "--billing", str(ports["billing"]),
                         "--aime", str(ports["aime"]), "--database", str(ports["database"]))

        db_host = self.db_host_var.get().strip()
        db_user = self.db_user_var.get().strip()
        db_password = self.db_password_var.get().strip()
        db_name = self.db_name_var.get().strip()
        if db_host or db_user or db_password or db_name:
            core_yaml = install_root() / "Server" / "artemis" / "config" / "core.yaml"
            subprocess.run(
                [fgo_python(), str(set_core_database_path()), str(core_yaml), db_host, db_user, db_password, db_name],
                capture_output=True, text=True, timeout=10, check=True,
            )


class NewAccountDialog(tk.Toplevel):
    def __init__(self, parent):
        super().__init__(parent)
        self.title("New account")
        self.resizable(False, False)
        self.result = None

        ttk.Label(self, text="Master name:").grid(row=0, column=0, sticky="w", padx=10, pady=(10, 4))
        self.name_var = tk.StringVar(value="Master")
        ttk.Entry(self, textvariable=self.name_var, width=30).grid(row=0, column=1, padx=10, pady=(10, 4))

        ttk.Label(self, text="Mode:").grid(row=1, column=0, sticky="w", padx=10, pady=4)
        self.mode_var = tk.StringVar(value="normal")
        modes = [("Normal (plain new account)", "normal"), ("Test - all Servants unlocked", "test_full")]
        for i, (label, value) in enumerate(modes):
            ttk.Radiobutton(self, text=label, variable=self.mode_var, value=value).grid(
                row=2 + i, column=0, columnspan=2, sticky="w", padx=10)

        buttons = ttk.Frame(self)
        buttons.grid(row=4, column=0, columnspan=2, pady=10)
        ttk.Button(buttons, text="Create", command=self._create).pack(side="left", padx=4)
        ttk.Button(buttons, text="Cancel", command=self.destroy).pack(side="left", padx=4)
        self.transient(parent)
        self.grab_set()

    def _create(self):
        name = self.name_var.get().strip()
        if not name:
            messagebox.showerror("Name required", "Enter a master name.")
            return
        self.result = (name, self.mode_var.get())
        self.destroy()


UPGRADE_ACTIONS = [
    ("Grant All Servants", "servants"), ("Grant All Craft Essences", "craft-essences"),
    ("Clear Present Box", "clear-gifts"), ("Clear All Quests", "quests"),
    ("Max All Bond", "bond"), ("Unlock All Costumes", "costumes"),
    ("Max All Materials", "materials"), ("Max All Servants", "levels"),
    ("Max Master Level", "master"),
]


class GrantItemsDialog(tk.Toplevel):
    def __init__(self, parent, aime_id):
        super().__init__(parent)
        self.aime_id = aime_id
        self.title(f"Grant items - account {aime_id}")
        self.geometry("520x420")

        top = ttk.Frame(self, padding=10)
        top.pack(fill="x")
        ttk.Label(top, text="Search:").pack(side="left")
        self.search_var = tk.StringVar()
        self.search_var.trace_add("write", lambda *_: self._apply_filter())
        ttk.Entry(top, textvariable=self.search_var, width=30).pack(side="left", padx=(4, 0))

        columns = ("category", "name", "current", "amount")
        self.tree = ttk.Treeview(self, columns=columns, show="headings", height=14)
        for col, label, width in (("category", "Category", 130), ("name", "Item", 220),
                                   ("current", "Current", 70), ("amount", "Grant amount", 100)):
            self.tree.heading(col, text=label)
            self.tree.column(col, width=width, anchor="w")
        self.tree.pack(fill="both", expand=True, padx=10)
        self.tree.bind("<Double-Button-1>", self._edit_amount)

        buttons = ttk.Frame(self, padding=10)
        buttons.pack(fill="x")
        ttk.Label(buttons, text="Double-click a row's amount to edit it, then Grant.", foreground="gray").pack(side="left")
        ttk.Button(buttons, text="Grant", command=self._grant).pack(side="right")
        ttk.Button(buttons, text="Cancel", command=self.destroy).pack(side="right", padx=(0, 8))

        self.items = []
        self.amounts = {}
        self.status_var = tk.StringVar(value="Loading catalog...")
        ttk.Label(self, textvariable=self.status_var, foreground="gray").pack(anchor="w", padx=10, pady=(0, 6))
        self.after(50, self._load_catalog)
        self.transient(parent)
        self.grab_set()

    def _load_catalog(self):
        try:
            data = run_account_tool("catalog", "--aime-id", str(self.aime_id), timeout=30)
            self.items = data.get("items", [])
            self.status_var.set(f"{len(self.items)} grantable item(s).")
        except Exception as exc:
            self.status_var.set(f"Could not load catalog: {exc}")
        self._apply_filter()

    def _apply_filter(self):
        query = self.search_var.get().strip().lower()
        self.tree.delete(*self.tree.get_children())
        for item in self.items:
            if query and query not in item["name"].lower() and query not in item["category"].lower():
                continue
            amount = self.amounts.get(item["key"], 0)
            self.tree.insert("", "end", iid=item["key"], values=(item["category"], item["name"], item["current"], amount))

    def _edit_amount(self, event):
        selection = self.tree.selection()
        if not selection:
            return
        key = selection[0]
        current = simpledialog.askinteger("Amount", "Grant amount:", initialvalue=self.amounts.get(key, 0), minvalue=0)
        if current is not None:
            self.amounts[key] = current
            self._apply_filter()

    def _grant(self):
        entries = [f"{key}={amount}" for key, amount in self.amounts.items() if amount > 0]
        if not entries:
            messagebox.showinfo("Nothing to grant", "Set an amount for at least one item first.")
            return
        try:
            args = ["grant", "--aime-id", str(self.aime_id)]
            for entry in entries:
                args += ["--item", entry]
            run_account_tool(*args, timeout=30)
            messagebox.showinfo("Granted", f"Granted {len(entries)} item(s).")
            self.destroy()
        except Exception as exc:
            messagebox.showerror("Could not grant items", str(exc))


class PrintHistoryDialog(tk.Toplevel):
    def __init__(self, parent, account):
        super().__init__(parent)
        self.title(f"Print history - {account['master_name']} (Aime {account['aime_id']})")
        self.geometry("640x400")
        ttk.Label(self, text=f"{account.get('summon_result_count', 0):,} total prints "
                              f"({len(account.get('summon_history', []))} shown)",
                  padding=10).pack(anchor="w")
        columns = ("when", "name", "type")
        tree = ttk.Treeview(self, columns=columns, show="headings")
        for col, label, width in (("when", "Confirmed", 160), ("name", "Card", 340), ("type", "Type", 100)):
            tree.heading(col, text=label)
            tree.column(col, width=width, anchor="w")
        tree.pack(fill="both", expand=True, padx=10, pady=(0, 10))
        for entry in account.get("summon_history", []):
            tree.insert("", "end", values=(entry.get("confirmed_at", ""), entry.get("display_name", ""),
                                            "Servant" if entry.get("servant_id") else "Craft Essence"))
        self.transient(parent)


class AccountTab(ttk.Frame):
    def __init__(self, parent):
        super().__init__(parent, padding=16)
        columns = ("aime_id", "master_name", "mode", "servants", "cards", "current")
        self.tree = ttk.Treeview(self, columns=columns, show="headings", height=8)
        headings = {"aime_id": "Aime ID", "master_name": "Name", "mode": "Mode",
                    "servants": "Servants", "cards": "Cards", "current": "In use"}
        for col in columns:
            self.tree.heading(col, text=headings[col])
            self.tree.column(col, width=90, anchor="w")
        self.tree.pack(fill="x")
        self.tree.bind("<<TreeviewSelect>>", lambda e: self._update_details())

        button_row = ttk.Frame(self)
        button_row.pack(fill="x", pady=(10, 0))
        ttk.Button(button_row, text="Refresh", command=self.refresh).pack(side="left")
        ttk.Button(button_row, text="New Account...", command=self._new_account).pack(side="left", padx=(8, 0))
        ttk.Button(button_row, text="Use Selected", command=self._use_selected).pack(side="left", padx=(8, 0))
        ttk.Button(button_row, text="Delete Selected", command=self._delete_selected).pack(side="left", padx=(8, 0))

        button_row2 = ttk.Frame(self)
        button_row2.pack(fill="x", pady=(6, 0))
        ttk.Button(button_row2, text="Reset to a New Account", command=self._reset_selected).pack(side="left")
        ttk.Button(button_row2, text="Repair Past Results", command=self._repair_selected).pack(side="left", padx=(8, 0))
        ttk.Button(button_row2, text="Grant Items", command=self._grant_items).pack(side="left", padx=(8, 0))
        ttk.Button(button_row2, text="Print History", command=self._print_history).pack(side="left", padx=(8, 0))

        self.details_var = tk.StringVar(value="")
        ttk.Label(self, textvariable=self.details_var).pack(anchor="w", pady=(10, 0))

        growth = ttk.LabelFrame(self, text="One-Click Inventory and Growth (selected account)", padding=10)
        growth.pack(fill="x", pady=(10, 0))
        for index, (label, tag) in enumerate(UPGRADE_ACTIONS):
            r, c = divmod(index, 3)
            ttk.Button(growth, text=label, width=22,
                       command=lambda t=tag, l=label: self._upgrade(t, l)).grid(row=r, column=c, padx=4, pady=4)

        self.status_var = tk.StringVar(value="")
        ttk.Label(self, textvariable=self.status_var, foreground="gray", wraplength=700).pack(anchor="w", pady=(10, 0))

        self._accounts_by_iid = {}
        self.refresh()

    def refresh(self):
        self.status_var.set("Loading...")
        self.update_idletasks()
        try:
            data = run_account_tool("list")
        except Exception as exc:
            self.status_var.set(f"Could not load accounts: {exc}")
            return
        self.tree.delete(*self.tree.get_children())
        self._accounts_by_iid.clear()
        for account in data.get("accounts", []):
            iid = str(account["aime_id"])
            self.tree.insert("", "end", iid=iid, values=(
                account["aime_id"], account["master_name"], account["account_mode"],
                account["servant_count"], account["owned_card_count"],
                "yes" if account["is_current"] else "",
            ))
            self._accounts_by_iid[iid] = account
            if account["is_current"]:
                self.tree.selection_set(iid)
        self.status_var.set(f"{len(data.get('accounts', []))} account(s). Server running: {data.get('server_running')}.")
        self._update_details()

    def _update_details(self):
        account = self._accounts_by_iid.get(self.tree.selection()[0]) if self.tree.selection() else None
        if not account:
            self.details_var.set("")
            return
        self.details_var.set(
            f"Lv.{account.get('master_level', '?')} - EXP {account.get('master_exp', 0):,} - "
            f"Quests cleared {account.get('cleared_quest_count', 0):,} - "
            f"Cards printed {account.get('owned_card_count', 0):,} - "
            f"Pending {account.get('pending_print_count', 0)}"
        )

    def _selected_account(self):
        selection = self.tree.selection()
        if not selection:
            messagebox.showinfo("No selection", "Select an account first.")
            return None
        return self._accounts_by_iid.get(selection[0])

    def _new_account(self):
        dialog = NewAccountDialog(self.winfo_toplevel())
        self.wait_window(dialog)
        if not dialog.result:
            return
        name, mode = dialog.result
        try:
            run_account_tool("create", "--name", name, "--mode", mode, timeout=60)
            self.status_var.set(f"Created account '{name}'.")
            self.refresh()
        except Exception as exc:
            messagebox.showerror("Could not create account", str(exc))

    def _use_selected(self):
        account = self._selected_account()
        if not account:
            return
        try:
            run_account_tool("use", "--aime-id", str(account["aime_id"]))
            self.status_var.set(f"Now using account {account['aime_id']} ({account['master_name']}).")
            self.refresh()
        except Exception as exc:
            messagebox.showerror("Could not switch account", str(exc))

    def _delete_selected(self):
        account = self._selected_account()
        if not account:
            return
        if not messagebox.askyesno("Confirm deletion",
                                    f"Permanently delete account {account['aime_id']} ({account['master_name']})? "
                                    "This deletes save data and cannot be undone."):
            return
        try:
            run_account_tool("delete", "--aime-id", str(account["aime_id"]), "--yes")
            self.status_var.set(f"Deleted account {account['aime_id']}.")
            self.refresh()
        except Exception as exc:
            messagebox.showerror("Could not delete account", str(exc))

    def _reset_selected(self):
        account = self._selected_account()
        if not account:
            return
        if not messagebox.askyesno("Confirm reset",
                                    f"Reset account {account['aime_id']} ({account['master_name']}) to a new account? "
                                    "Servants, resources and progress are cleared. This cannot be undone."):
            return
        try:
            run_account_tool("reset", "--aime-id", str(account["aime_id"]), timeout=60)
            self.status_var.set(f"Reset account {account['aime_id']}.")
            self.refresh()
        except Exception as exc:
            messagebox.showerror("Could not reset account", str(exc))

    def _repair_selected(self):
        account = self._selected_account()
        if not account:
            return
        try:
            run_account_tool("repair", "--aime-id", str(account["aime_id"]), timeout=60)
            self.status_var.set(f"Repaired account {account['aime_id']} from captured cabinet results.")
            self.refresh()
        except Exception as exc:
            messagebox.showerror("Could not repair account", str(exc))

    def _grant_items(self):
        account = self._selected_account()
        if not account:
            return
        dialog = GrantItemsDialog(self.winfo_toplevel(), account["aime_id"])
        self.wait_window(dialog)
        self.refresh()

    def _print_history(self):
        account = self._selected_account()
        if not account:
            return
        PrintHistoryDialog(self.winfo_toplevel(), account)

    def _upgrade(self, tag, label):
        account = self._selected_account()
        if not account:
            return
        try:
            run_account_tool("upgrade", "--aime-id", str(account["aime_id"]), "--action", tag, timeout=60)
            self.status_var.set(f"{label}: done for account {account['aime_id']}.")
            self.refresh()
        except Exception as exc:
            messagebox.showerror(f"Could not run '{label}'", str(exc))


def _variant_label(card):
    # file_name looks like "00002_CE00002_A00_NORMAL.bmp" - the trailing
    # underscore-separated segment(s) before the extension are the card's
    # art/stage variant (NORMAL, FATAL_FOIL, an ascension stage, etc.).
    stem = Path(card["file_name"]).stem
    parts = stem.split("_")
    variant = " ".join(p.title() for p in parts[2:]) if len(parts) > 2 else stem
    return f"{variant} - TC {card['tc_id']}"


class CardDetailDialog(tk.Toplevel):
    """The "Choose Card Type and Quantity" dialog - one underlying card
    (Servant or Craft Essence) can print as several distinct variants
    (Normal/Fatal Foil art, different ascension stages, etc.), each its own
    entry in owned_cards/deck.json. Lets you set a quantity per variant in
    one place instead of hunting each one down in the grid."""

    def __init__(self, parent, card, variants, selected, thumbnail_fn):
        super().__init__(parent)
        self.selected = selected
        self.changed = False
        self.qty_vars = {}
        name = DeckTab._display_name(card)
        japanese = TRANSLATIONS.japanese_name(card)
        internal_id = TRANSLATIONS.internal_id(card) or "?"
        self.title(name)
        self.resizable(False, False)

        header = ttk.Frame(self, padding=12)
        header.pack(fill="x")
        photo = thumbnail_fn(card)
        if photo is not None:
            image_label = tk.Label(header, image=photo)
            image_label.image = photo
            image_label.pack(side="left", padx=(0, 12))
        text_frame = ttk.Frame(header)
        text_frame.pack(side="left", fill="both", expand=True)
        ttk.Label(text_frame, text=name, font=("", 13, "bold")).pack(anchor="w")
        if japanese:
            ttk.Label(text_frame, text=japanese, foreground="gray").pack(anchor="w")
        ttk.Label(text_frame, text=f"Internal ID {internal_id}", foreground="gray").pack(anchor="w")

        effect = TRANSLATIONS.craft_essence_effect(card)
        if effect:
            effect_frame = ttk.LabelFrame(self, text="Effect", padding=10)
            effect_frame.pack(fill="x", padx=12, pady=(0, 8))
            if effect.get("Normal"):
                ttk.Label(effect_frame, text="Normal:", font=("", 9, "bold")).pack(anchor="w")
                ttk.Label(effect_frame, text=effect["Normal"], wraplength=420).pack(anchor="w")
                ttk.Label(effect_frame, text=effect.get("NormalJapanese", ""), foreground="gray", wraplength=420).pack(anchor="w", pady=(0, 6))
            if effect.get("Maximum"):
                ttk.Label(effect_frame, text="Max Limit Break:", font=("", 9, "bold")).pack(anchor="w")
                ttk.Label(effect_frame, text=effect["Maximum"], wraplength=420).pack(anchor="w")
                ttk.Label(effect_frame, text=effect.get("MaximumJapanese", ""), foreground="gray", wraplength=420).pack(anchor="w")

        table = ttk.Frame(self, padding=(12, 0))
        table.pack(fill="both", expand=True)
        headers = ["Variant", "Owned", "In Deck", "Quantity"]
        for col, text in enumerate(headers):
            ttk.Label(table, text=text, font=("", 9, "bold")).grid(row=0, column=col, sticky="w", padx=6, pady=4)
        for row, variant in enumerate(variants, start=1):
            file_name = variant["file_name"]
            owned = variant["count"]
            current_qty = self.selected[file_name]["qty"].get() if file_name in self.selected else 0
            ttk.Label(table, text=_variant_label(variant)).grid(row=row, column=0, sticky="w", padx=6, pady=2)
            ttk.Label(table, text=str(owned)).grid(row=row, column=1, padx=6)
            ttk.Label(table, text=str(current_qty)).grid(row=row, column=2, padx=6)
            qty_var = tk.IntVar(value=current_qty)
            self.qty_vars[file_name] = (qty_var, variant)
            ttk.Spinbox(table, from_=0, to=max(owned, 0), textvariable=qty_var, width=6).grid(row=row, column=3, padx=6)

        buttons = ttk.Frame(self, padding=12)
        buttons.pack(fill="x")
        ttk.Button(buttons, text="Cancel", command=self.destroy).pack(side="right")
        ttk.Button(buttons, text="Add Selected Quantities", command=self._apply).pack(side="right", padx=(0, 8))
        self.transient(parent)
        self.grab_set()

    def _apply(self):
        for file_name, (qty_var, variant) in self.qty_vars.items():
            qty = qty_var.get()
            if qty > 0:
                self.selected[file_name] = {"card": variant, "qty": tk.IntVar(value=qty)}
            elif file_name in self.selected:
                del self.selected[file_name]
        self.changed = True
        self.destroy()


class DeckTab(ttk.Frame):
    """Card grid is built entirely from live data: fgo_account.py's own
    owned_cards for whichever account is currently in use, and thumbnail
    images loaded from CardsPath (deck.json's own field, defaulting to
    DEVICE/print/FGO11_AllServants) - nothing about specific cards/IDs is
    hardcoded here, matching how scooby.exe itself works."""

    PAGE_SIZE = 48
    THUMB_SIZE = (72, 111)

    def __init__(self, parent):
        super().__init__(parent, padding=12)
        self.thumb_cache = {}  # file_name -> ImageTk.PhotoImage
        self.owned_cards = []
        self.filtered_cards = []
        self.page = 0
        self.selected = {}  # file_name -> {"card": card_dict, "qty": IntVar}
        self.cards_path = None

        if not HAVE_PIL:
            ttk.Label(self, text="Pillow (python3-Pillow) is required for the deck editor's card artwork - install it and restart.",
                      foreground="red", wraplength=500).pack(padx=8, pady=8)
            return

        top = ttk.Frame(self)
        top.pack(fill="x")
        ttk.Label(top, text="Search:").pack(side="left")
        self.search_var = tk.StringVar()
        self.search_var.trace_add("write", lambda *_: self._apply_filter())
        ttk.Entry(top, textvariable=self.search_var, width=30).pack(side="left", padx=(4, 12))
        ttk.Button(top, text="Reload from account", command=self.reload).pack(side="left")
        self.page_label_var = tk.StringVar(value="")
        ttk.Label(top, textvariable=self.page_label_var).pack(side="left", padx=(12, 0))
        ttk.Button(top, text="< Prev", command=self._prev_page).pack(side="left", padx=(12, 0))
        ttk.Button(top, text="Next >", command=self._next_page).pack(side="left", padx=(4, 0))

        body = ttk.Frame(self)
        body.pack(fill="both", expand=True, pady=(8, 0))

        grid_container = ttk.Frame(body)
        grid_container.pack(side="left", fill="both", expand=True)
        self.grid_canvas = tk.Canvas(grid_container, highlightthickness=0)
        grid_scroll = ttk.Scrollbar(grid_container, orient="vertical", command=self.grid_canvas.yview)
        self.grid_canvas.configure(yscrollcommand=grid_scroll.set)
        grid_scroll.pack(side="right", fill="y")
        self.grid_canvas.pack(side="left", fill="both", expand=True)
        self.grid_frame = ttk.Frame(self.grid_canvas)
        self.grid_canvas.create_window((0, 0), window=self.grid_frame, anchor="nw")
        self.grid_frame.bind("<Configure>", lambda e: self.grid_canvas.configure(scrollregion=self.grid_canvas.bbox("all")))

        side = ttk.Frame(body, width=220)
        side.pack(side="left", fill="y", padx=(10, 0))
        ttk.Label(side, text="Selected deck:").pack(anchor="w")
        self.selected_list = tk.Listbox(side, width=32, height=22)
        self.selected_list.pack(fill="y", expand=False)
        ttk.Button(side, text="Remove selected", command=self._remove_from_deck_list).pack(fill="x", pady=(4, 0))
        ttk.Button(side, text="Save Deck", command=self.save).pack(fill="x", pady=(8, 0))

        self.status_var = tk.StringVar(value="")
        ttk.Label(self, textvariable=self.status_var, foreground="gray", wraplength=700).pack(anchor="w", pady=(6, 0))

        self.reload()

    def _resolve_cards_path(self):
        try:
            deck = json.loads(deck_json_path().read_text(encoding="utf-8"))
            raw = deck.get("CardsPath") or ""
        except (OSError, json.JSONDecodeError):
            raw = ""
        if not raw:
            raw = "../DEVICE/print/FGO11_AllServants"
        return (install_root() / "App" / raw.replace("\\", "/")).resolve()

    def reload(self):
        self.status_var.set("Loading account data...")
        self.update_idletasks()
        try:
            data = run_account_tool("list")
        except Exception as exc:
            self.status_var.set(f"Could not load account data: {exc}")
            return
        current = next((a for a in data.get("accounts", []) if a.get("is_current")), None)
        if current is None and data.get("accounts"):
            current = data["accounts"][0]
        if current is None:
            self.status_var.set("No account found - create one in the Account tab first.")
            self.owned_cards = []
        else:
            self.owned_cards = current.get("owned_cards", [])
        self.cards_path = self._resolve_cards_path()

        self.selected.clear()
        try:
            deck = json.loads(deck_json_path().read_text(encoding="utf-8"))
            selected_paths = deck.get("SelectedCards") or []
            selected_copies = deck.get("SelectedCardCopies") or []
            by_file = {c["file_name"]: c for c in self.owned_cards}
            for path, qty in zip(selected_paths, selected_copies):
                file_name = Path(path.replace("\\", "/")).name
                card = by_file.get(file_name)
                if card:
                    self.selected[file_name] = {"card": card, "qty": tk.IntVar(value=qty)}
        except (OSError, json.JSONDecodeError):
            pass

        self.page = 0
        self._apply_filter()
        self._refresh_selected_list()
        who = current["master_name"] if current else "no account"
        self.status_var.set(f"{len(self.owned_cards)} owned card(s) for {who}. Cards read from {self.cards_path}.")

    def _apply_filter(self):
        query = self.search_var.get().strip().lower()
        if query:
            self.filtered_cards = [c for c in self.owned_cards
                                    if query in c["display_name"].lower() or query in c["file_name"].lower()]
        else:
            self.filtered_cards = list(self.owned_cards)
        self.page = 0
        self._render_page()

    def _prev_page(self):
        if self.page > 0:
            self.page -= 1
            self._render_page()

    def _next_page(self):
        if (self.page + 1) * self.PAGE_SIZE < len(self.filtered_cards):
            self.page += 1
            self._render_page()

    def _thumbnail(self, card):
        file_name = card["file_name"]
        if file_name in self.thumb_cache:
            return self.thumb_cache[file_name]
        path = self.cards_path / file_name
        try:
            image = Image.open(path)
            image.thumbnail(self.THUMB_SIZE)
            photo = ImageTk.PhotoImage(image)
        except (OSError, ValueError):
            photo = None
        self.thumb_cache[file_name] = photo
        return photo

    @staticmethod
    def _display_name(card):
        return TRANSLATIONS.english_name(card) or card["display_name"]

    def _render_page(self):
        for child in self.grid_frame.winfo_children():
            child.destroy()
        start = self.page * self.PAGE_SIZE
        page_cards = self.filtered_cards[start:start + self.PAGE_SIZE]
        columns = 6
        for index, card in enumerate(page_cards):
            r, c = divmod(index, columns)
            cell = ttk.Frame(self.grid_frame, padding=4,
                              relief="solid" if card["file_name"] in self.selected else "flat",
                              borderwidth=2 if card["file_name"] in self.selected else 0)
            cell.grid(row=r, column=c, padx=3, pady=3)
            photo = self._thumbnail(card)
            if photo is not None:
                label = tk.Label(cell, image=photo, cursor="hand2")
                label.image = photo
            else:
                label = tk.Label(cell, text="(no image)", width=10, height=6, cursor="hand2")
            label.pack()
            name_label = ttk.Label(cell, text=self._display_name(card)[:22], width=16, wraplength=110)
            name_label.pack()
            for widget in (cell, label, name_label):
                widget.bind("<Button-1>", lambda e, c=card: self._toggle_card(c))
                widget.bind("<Double-Button-1>", lambda e, c=card: self._open_detail(c))
        total_pages = max(1, (len(self.filtered_cards) + self.PAGE_SIZE - 1) // self.PAGE_SIZE)
        self.page_label_var.set(f"Page {self.page + 1}/{total_pages} ({len(self.filtered_cards)} matching)")

    def _toggle_card(self, card):
        file_name = card["file_name"]
        if file_name in self.selected:
            del self.selected[file_name]
        else:
            self.selected[file_name] = {"card": card, "qty": tk.IntVar(value=1)}
        self._render_page()
        self._refresh_selected_list()

    def _open_detail(self, card):
        internal_id = TRANSLATIONS.internal_id(card)
        variants = [c for c in self.owned_cards
                    if TRANSLATIONS.internal_id(c) == internal_id] if internal_id else [card]
        dialog = CardDetailDialog(self.winfo_toplevel(), card, variants, self.selected, self._thumbnail)
        self.wait_window(dialog)
        if dialog.changed:
            self._render_page()
            self._refresh_selected_list()

    def _refresh_selected_list(self):
        self.selected_list.delete(0, "end")
        for file_name, entry in self.selected.items():
            self.selected_list.insert("end", f"{entry['qty'].get()}x {self._display_name(entry['card'])[:28]}")

    def _remove_from_deck_list(self):
        selection = self.selected_list.curselection()
        if not selection:
            return
        file_name = list(self.selected.keys())[selection[0]]
        del self.selected[file_name]
        self._render_page()
        self._refresh_selected_list()

    def save(self):
        if not self.selected:
            if not messagebox.askyesno("Empty deck", "No cards selected - save an empty deck anyway?"):
                return
        relative_cards_path = os.path.relpath(self.cards_path, install_root() / "App").replace("/", "\\")
        selected_cards = [f"{relative_cards_path}\\{entry['card']['file_name']}" for entry in self.selected.values()]
        selected_copies = [entry["qty"].get() for entry in self.selected.values()]
        deck_json_path().write_text(json.dumps({
            "SelectedCards": selected_cards,
            "SelectedCardCopies": selected_copies,
            "CardsPath": relative_cards_path,
        }, ensure_ascii=False, indent=2), encoding="utf-8")
        self.status_var.set(f"Saved {len(selected_cards)} card(s) to deck.json.")


class App(tk.Tk):
    def __init__(self):
        super().__init__()
        root = install_root_or_none()
        self.title(f"FGO Arcade settings - {root or '(no install configured)'}")
        self.geometry("900x680")

        self.notebook = ttk.Notebook(self)
        self.notebook.pack(fill="both", expand=True, padx=8, pady=8)

        self.setup_tab = SetupTab(self.notebook, on_saved=self._on_setup_saved)
        self.notebook.add(self.setup_tab, text="Setup")

        self.display_tab = self.controls_tab = self.server_tab = None
        self.account_tab = self.deck_tab = None
        if root is not None:
            self._build_install_tabs()
        else:
            placeholder = ttk.Frame(self.notebook, padding=24)
            ttk.Label(placeholder, text="No FGO Arcade install configured yet.\n"
                                         "Fill in the Setup tab, click Save, then restart this app.",
                      justify="center").pack(expand=True)
            self.notebook.add(placeholder, text="(configure Setup first)")

        button_row = ttk.Frame(self, padding=(8, 0, 8, 8))
        button_row.pack(fill="x")
        ttk.Button(button_row, text="Save", command=self.on_save).pack(side="left")
        ttk.Button(button_row, text="Save && Play", command=self.on_play).pack(side="left", padx=(8, 0))
        self.status_var = tk.StringVar(value="")
        ttk.Label(button_row, textvariable=self.status_var, foreground="gray").pack(side="left", padx=(16, 0))

    def _build_install_tabs(self):
        self.display_tab = DisplayTab(self.notebook)
        self.controls_tab = ControlsTab(self.notebook)
        self.server_tab = ServerTab(self.notebook)
        self.account_tab = AccountTab(self.notebook)
        self.deck_tab = DeckTab(self.notebook)
        self.notebook.add(self.display_tab, text="Display")
        self.notebook.add(self.controls_tab, text="Controls")
        self.notebook.add(self.server_tab, text="Server")
        self.notebook.add(self.account_tab, text="Account")
        self.notebook.add(self.deck_tab, text="Deck")

    def _on_setup_saved(self):
        if install_root_or_none() is not None and self.display_tab is None:
            messagebox.showinfo("Restart needed", "Install root configured - restart this app to load its settings.")

    def _save_all(self):
        if self.display_tab is None:
            return  # only the Setup tab exists - nothing else to save
        self.display_tab.save()
        self.controls_tab.save()
        self.server_tab.save()

    def on_save(self):
        try:
            self.setup_tab.save()
            self._save_all()
            self.status_var.set("Saved.")
        except Exception as exc:
            messagebox.showerror("Could not save", str(exc))

    def on_play(self):
        if self.display_tab is None:
            messagebox.showerror("Not configured", "Configure and save the Setup tab, then restart, before playing.")
            return
        try:
            self._save_all()
        except Exception as exc:
            messagebox.showerror("Could not save", str(exc))
            return
        linux_dir = Path(__file__).resolve().parent.parent  # linux/tools -> linux
        env = dict(os.environ)
        env.update(self.display_tab.play_env())
        try:
            subprocess.Popen([str(linux_dir / "fgo-launcher.sh")], env=env)
            self.status_var.set("Launching...")
        except Exception as exc:
            messagebox.showerror("Could not launch", str(exc))


def main():
    app = App()
    app.mainloop()


if __name__ == "__main__":
    main()
