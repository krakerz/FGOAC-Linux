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
import re
import shutil
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
    from evdev import ff
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

# xinput's "movement" key (which physical input drives on-field movement) -
# scooby's own MovementSelector, 0-indexed.
MOVEMENT_CHOICES = [("Left Stick", 0), ("Right Stick", 1), ("D-Pad", 2)]
MOVEMENT_VALUE_TO_NAME = {v: n for n, v in MOVEMENT_CHOICES}

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


def _ff_devices():
    """Force-feedback-capable evdev devices, ordered by /dev/input/eventN -
    a best-effort stand-in for however Wine's own XInput backend numbers
    connected pads (there's no way to query that ordering from here), used
    only to let "Vibrate to test" identify roughly the right physical pad."""
    devices = []
    for path in evdev.list_devices():
        try:
            dev = evdev.InputDevice(path)
        except OSError:
            continue
        if evdev.ecodes.EV_FF in dev.capabilities():
            devices.append(dev)
    match = re.compile(r"(\d+)$")
    devices.sort(key=lambda d: int(match.search(d.path).group()) if match.search(d.path) else 0)
    return devices


def _rumble_device(dev, duration_ms=600, strength=0xFFFF):
    effect = ff.Effect(
        evdev.ecodes.FF_RUMBLE, -1, 0,
        ff.Trigger(0, 0),
        ff.Replay(duration_ms, 0),
        ff.EffectType(ff_rumble_effect=ff.Rumble(strong_magnitude=strength, weak_magnitude=strength)),
    )
    effect_id = dev.upload_effect(effect)
    dev.write(evdev.ecodes.EV_FF, effect_id, 1)
    return effect_id


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

# Advanced graphics choices - values/labels match scooby's own MainWindow.xaml
# (SmaaComboBox/AnisotropyComboBox/RenderScaleComboBox/ShadowResolutionComboBox)
# exactly, so a setting picked here reads the same in either tool.
SMAA_CHOICES = [("Off (native)", 0), ("Native + SMAA High", 1), ("Native + SMAA Ultra", 2)]
SMAA_VALUE_TO_NAME = {v: n for n, v in SMAA_CHOICES}
ANISOTROPY_CHOICES = [("1x", 1), ("2x", 2), ("4x", 4), ("8x", 8), ("16x", 16)]
ANISOTROPY_VALUE_TO_NAME = {v: n for n, v in ANISOTROPY_CHOICES}
RENDER_SCALE_CHOICES = [("100% (native)", 100), ("125% (1.56x pixels)", 125),
                         ("150% (2.25x pixels)", 150), ("200% (4x pixels)", 200)]
RENDER_SCALE_VALUE_TO_NAME = {v: n for n, v in RENDER_SCALE_CHOICES}
SHADOW_RESOLUTION_CHOICES = [("Game default", 0), ("1024 x 1024", 1024), ("2048 x 2048", 2048), ("4096 x 4096", 4096)]
SHADOW_RESOLUTION_VALUE_TO_NAME = {v: n for n, v in SHADOW_RESOLUTION_CHOICES}

# Deck tab "Show"/"Sort" choices - match scooby's own CardTypeComboBox/
# CardSortComboBox (mainwindow.xaml) tag values exactly.
CARD_TYPE_CHOICES = [("All Cards", 0), ("Servants", 1), ("Craft Essences", 2)]
CARD_SORT_CHOICES = [("Folder order", 0), ("Name", 1), ("Card number", 2)]


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


def loadout_folder():
    return install_root() / "App" / "deck-loadouts"


def card_manifest_path():
    # Fixed location - unlike deck.json's own (overridable) CardsPath, this
    # is exactly where fgo_account.py's own load_card_manifest_by_id() reads
    # it from (Server/tools/fgo_account.py), so it's always the same file
    # the account tool itself uses to resolve tc_id -> card metadata.
    return install_root() / "DEVICE" / "print" / "FGO11_AllServants" / "library-manifest.json"


def load_card_catalog():
    """The full card roster (owned or not) - tc_id -> a dict in the exact
    same shape fgo_account.py's own owned_cards entries use, straight from
    the game's own library-manifest.json (not generated or guessed at here).
    Every entry starts at count 0; DeckTab overlays the account's real
    owned counts on top. Missing/unreadable just means "All Cards" can only
    show what's actually owned - the same as before this existed."""
    try:
        manifest = json.loads(card_manifest_path().read_text(encoding="utf-8-sig"))
    except (OSError, ValueError):
        return {}
    catalog = {}
    for card in manifest.get("Cards", []):
        if not isinstance(card, dict):
            continue
        try:
            tc_id = int(card["TradingCardId"])
        except (KeyError, TypeError, ValueError):
            continue
        catalog[tc_id] = {
            "tc_id": tc_id,
            "count": 0,
            "card_type_id": int(card.get("CardTypeId", 1)),
            "servant_id": int(card.get("ServantId", 0)),
            "craft_essence_id": int(card.get("CraftEssenceId", 0)),
            "display_name": str(card.get("DisplayName", f"Trading Card {tc_id}")),
            "file_name": str(card.get("FileName", "")),
        }
    return catalog


def _patch_fgo_account_windows_only_check():
    """fgo_account.py's own purge_player_prints() (run on every account
    delete) checks a Windows-only NTFS reparse-point attribute
    (os.stat_result.st_file_attributes) that doesn't exist under Linux's
    os.stat() at all - AttributeError on every single delete when run with
    our native FGO_PYTHON instead of the game's bundled Windows python.exe.
    Patched in place, staying Windows-identical wherever the attribute
    exists (a no-op there) and simply skipping the reparse-point check where
    it doesn't (is_symlink() alongside it already covers Linux's own
    equivalent). Idempotent - cheap to re-check before every call, so a
    fresh/regenerated install reintroducing the unpatched file self-heals
    without needing a separate one-time setup step."""
    path = account_tool_path()
    broken = "p.stat().st_file_attributes & 0x400"
    fixed = 'getattr(p.stat(), "st_file_attributes", 0) & 0x400'
    try:
        text = path.read_text(encoding="utf-8")
        if broken in text:
            path.write_text(text.replace(broken, fixed), encoding="utf-8")
    except OSError:
        pass  # best-effort - the real subprocess call below will surface any actual problem


def run_account_tool(*args, timeout=30):
    """Runs fgo_account.py with our own native FGO_PYTHON (the ARTEMiS venv -
    this script imports artemis's own core/titles modules, same as when the
    real server runs) rather than the game's bundled Windows python.exe under
    Wine - confirmed working identically, no Wine round-trip needed."""
    _patch_fgo_account_windows_only_check()
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
    """monitorDevice is deliberately not exposed here (per-machine, fiddly to
    get right, and fgo-launcher.sh fgo_die()s on an invalid value) -
    config_data still carries whatever's already on disk and save() never
    touches that key, so it round-trips untouched."""

    def __init__(self, parent):
        super().__init__(parent, padding=16)
        self.config_data = load_launcher_json()
        self.graphics_data = self.config_data.setdefault("graphics", {})

        notebook = ttk.Notebook(self)
        notebook.pack(fill="both", expand=True)
        basic = ttk.Frame(notebook, padding=12)
        advanced = ttk.Frame(notebook, padding=12)
        notebook.add(basic, text="Basic")
        notebook.add(advanced, text="Advanced Graphics")

        row = 0
        ttk.Label(basic, text="Resolution:").grid(row=row, column=0, sticky="w", pady=4)
        self.width_var = tk.StringVar(value=str(self.config_data.get("resolutionWidth", 1280)))
        self.height_var = tk.StringVar(value=str(self.config_data.get("resolutionHeight", 720)))
        ttk.Entry(basic, textvariable=self.width_var, width=8).grid(row=row, column=1, sticky="w")
        ttk.Label(basic, text="x").grid(row=row, column=2)
        ttk.Entry(basic, textvariable=self.height_var, width=8).grid(row=row, column=3, sticky="w")
        row += 1

        ttk.Label(basic, text="Display mode:").grid(row=row, column=0, sticky="w", pady=4)
        self.mode_var = tk.StringVar(value=self.config_data.get("displayMode", "windowed"))
        mode_names = [n for n, _ in DISPLAY_MODES]
        mode_by_name = dict(DISPLAY_MODES)
        name_by_mode = {v: n for n, v in DISPLAY_MODES}
        self.mode_display = tk.StringVar(value=name_by_mode.get(self.mode_var.get(), mode_names[0]))
        combo = ttk.Combobox(basic, textvariable=self.mode_display, values=mode_names, state="readonly", width=20)
        combo.grid(row=row, column=1, columnspan=3, sticky="w")
        self._mode_by_name = mode_by_name
        row += 1

        ttk.Label(basic, text="Target FPS:").grid(row=row, column=0, sticky="w", pady=4)
        self.fps_var = tk.StringVar(value=str(self.config_data.get("targetFps", 60)))
        ttk.Entry(basic, textvariable=self.fps_var, width=8).grid(row=row, column=1, sticky="w")
        row += 1

        self.gamescope_var = tk.BooleanVar(value=False)
        ttk.Checkbutton(basic, text="Run inside gamescope (experimental - known to exit early on this game)",
                        variable=self.gamescope_var).grid(row=row, column=0, columnspan=4, sticky="w", pady=(16, 0))
        row += 1
        self.gamescope_fullscreen_var = tk.BooleanVar(value=False)
        ttk.Checkbutton(basic, text="Fullscreen (gamescope only)",
                        variable=self.gamescope_fullscreen_var).grid(row=row, column=0, columnspan=4, sticky="w")

        # --- Advanced Graphics: fgo-launcher.json's own "graphics" object -
        # already fully wired through fgo-launcher.sh into FGO_* env vars the
        # injector reads (see GFX_*/FGO_HIDE_TARGET_LINES etc. there), just
        # never had GUI controls. Choices/ranges match scooby's own
        # MainWindow.xaml exactly.
        g = self.graphics_data
        row = 0
        ttk.Label(advanced, text="Anti-aliasing:", width=18).grid(row=row, column=0, sticky="w", pady=3)
        self.smaa_var = tk.StringVar(value=SMAA_VALUE_TO_NAME.get(g.get("smaa", 0), "Off (native)"))
        ttk.Combobox(advanced, textvariable=self.smaa_var, values=[n for n, _ in SMAA_CHOICES],
                     state="readonly", width=22).grid(row=row, column=1, sticky="w")
        ttk.Label(advanced, text="Anisotropic filtering:").grid(row=row, column=2, sticky="w", padx=(16, 0))
        self.anisotropy_var = tk.StringVar(value=ANISOTROPY_VALUE_TO_NAME.get(g.get("anisotropy", 16), "16x"))
        ttk.Combobox(advanced, textvariable=self.anisotropy_var, values=[n for n, _ in ANISOTROPY_CHOICES],
                     state="readonly", width=8).grid(row=row, column=3, sticky="w")
        row += 1

        ttk.Label(advanced, text="Render scale:", width=18).grid(row=row, column=0, sticky="w", pady=3)
        self.render_scale_var = tk.StringVar(value=RENDER_SCALE_VALUE_TO_NAME.get(g.get("renderScale", 100), "100% (native)"))
        ttk.Combobox(advanced, textvariable=self.render_scale_var, values=[n for n, _ in RENDER_SCALE_CHOICES],
                     state="readonly", width=22).grid(row=row, column=1, sticky="w")
        ttk.Label(advanced, text="Shadow resolution:").grid(row=row, column=2, sticky="w", padx=(16, 0))
        self.shadow_res_var = tk.StringVar(value=SHADOW_RESOLUTION_VALUE_TO_NAME.get(g.get("shadowResolution", 0), "Game default"))
        ttk.Combobox(advanced, textvariable=self.shadow_res_var, values=[n for n, _ in SHADOW_RESOLUTION_CHOICES],
                     state="readonly", width=14).grid(row=row, column=3, sticky="w")
        row += 1

        self.motion_blur_var = tk.BooleanVar(value=bool(g.get("motionBlur", False)))
        self.depth_of_field_var = tk.BooleanVar(value=bool(g.get("depthOfField", True)))
        self.bloom_var = tk.BooleanVar(value=bool(g.get("bloom", True)))
        self.no_camera_shake_var = tk.BooleanVar(value=bool(g.get("disableCameraShake", False)))
        toggles = ttk.Frame(advanced)
        toggles.grid(row=row, column=0, columnspan=4, sticky="w", pady=(10, 4))
        ttk.Checkbutton(toggles, text="Motion Blur", variable=self.motion_blur_var).pack(side="left", padx=(0, 16))
        ttk.Checkbutton(toggles, text="Depth of Field", variable=self.depth_of_field_var).pack(side="left", padx=(0, 16))
        ttk.Checkbutton(toggles, text="Bloom", variable=self.bloom_var).pack(side="left", padx=(0, 16))
        ttk.Checkbutton(toggles, text="No Camera Shake", variable=self.no_camera_shake_var).pack(side="left")
        row += 1

        self.hide_target_lines_var = tk.BooleanVar(value=bool(g.get("hideTargetLines", False)))
        ttk.Checkbutton(advanced, text="Hide Enemy Lock-on Lines", variable=self.hide_target_lines_var).grid(
            row=row, column=0, columnspan=4, sticky="w", pady=(4, 12))
        row += 1

        ttk.Separator(advanced, orient="horizontal").grid(row=row, column=0, columnspan=4, sticky="ew", pady=8)
        row += 1
        ttk.Label(advanced, text="Battle Damage Popups", font=("", 10, "bold")).grid(
            row=row, column=0, columnspan=4, sticky="w", pady=(0, 8))
        row += 1

        def numeric_row(label, value, lo, hi):
            nonlocal row
            ttk.Label(advanced, text=label, width=18).grid(row=row, column=0, sticky="w", pady=3)
            var = tk.StringVar(value=str(value))
            ttk.Entry(advanced, textvariable=var, width=10).grid(row=row, column=1, sticky="w")
            ttk.Label(advanced, text=f"({lo}-{hi}%)", foreground="gray").grid(row=row, column=2, sticky="w")
            row += 1
            return var

        self.damage_number_scale_var = numeric_row("Damage number size:", g.get("damageNumberScale", 100), 0, 200)
        self.damage_number_opacity_var = numeric_row("Number opacity:", g.get("damageNumberOpacity", 100), 0, 100)
        self.damage_texture_scale_var = numeric_row("Popup graphic size:", g.get("damageTextureScale", 100), 0, 200)
        self.damage_texture_opacity_var = numeric_row("Graphic opacity:", g.get("damageTextureOpacity", 100), 0, 100)

        ttk.Separator(advanced, orient="horizontal").grid(row=row, column=0, columnspan=4, sticky="ew", pady=8)
        row += 1

        self.hide_ui_var = tk.BooleanVar(value=bool(g.get("hideUi", False)))
        ttk.Checkbutton(advanced, text="Hide the UI When the Game Starts", variable=self.hide_ui_var).grid(
            row=row, column=0, columnspan=4, sticky="w", pady=(0, 4))
        row += 1
        self.hide_cabinet_hud_var = tk.BooleanVar(value=bool(g.get("hideCabinetHud", False)))
        ttk.Checkbutton(advanced, text="Hide the Cabinet HUD (GP, CREDIT, volume, status icons)",
                        variable=self.hide_cabinet_hud_var).grid(row=row, column=0, columnspan=4, sticky="w", pady=(0, 8))
        row += 1

        ttk.Label(advanced, text="Show/Hide UI shortcut:", width=20).grid(row=row, column=0, sticky="w", pady=3)
        hide_ui_key_current = int(g.get("hideUiKey", 121))
        self.hide_ui_key_var = tk.StringVar(value=KEY_VALUE_TO_NAME.get(hide_ui_key_current, f"0x{hide_ui_key_current:X}"))
        key_names = [n for n, _ in KEY_CHOICES]
        if self.hide_ui_key_var.get() not in key_names:
            key_names = key_names + [self.hide_ui_key_var.get()]
        ttk.Combobox(advanced, textvariable=self.hide_ui_key_var, values=key_names,
                     state="readonly", width=18).grid(row=row, column=1, sticky="w")

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

        def pct(var, lo, hi, label):
            try:
                value = float(var.get())
            except ValueError:
                raise ValueError(f"{label} must be a number.")
            if not (lo <= value <= hi):
                raise ValueError(f"{label} must be between {lo} and {hi}.")
            return value

        damage = (
            pct(self.damage_number_scale_var, 0, 200, "Damage number size"),
            pct(self.damage_number_opacity_var, 0, 100, "Number opacity"),
            pct(self.damage_texture_scale_var, 0, 200, "Popup graphic size"),
            pct(self.damage_texture_opacity_var, 0, 100, "Graphic opacity"),
        )
        return width, height, fps, damage

    def save(self):
        width, height, fps, damage = self.validate()
        damage_number_scale, damage_number_opacity, damage_texture_scale, damage_texture_opacity = damage
        self.config_data["resolutionWidth"] = width
        self.config_data["resolutionHeight"] = height
        self.config_data["targetFps"] = fps
        mode = self._mode_by_name[self.mode_display.get()]
        self.config_data["displayMode"] = mode
        self.config_data["windowed"] = mode != "exclusive"

        smaa_name_to_value = {n: v for n, v in SMAA_CHOICES}
        anisotropy_name_to_value = {n: v for n, v in ANISOTROPY_CHOICES}
        render_scale_name_to_value = {n: v for n, v in RENDER_SCALE_CHOICES}
        shadow_res_name_to_value = {n: v for n, v in SHADOW_RESOLUTION_CHOICES}
        key_name_to_value = {n: v for n, v in KEY_CHOICES}

        def resolve_key(name):
            if name in key_name_to_value:
                return key_name_to_value[name]
            return int(name, 16)  # a "0x..." fallback label from an unrecognized existing value

        self.graphics_data.update({
            "smaa": smaa_name_to_value[self.smaa_var.get()],
            "anisotropy": anisotropy_name_to_value[self.anisotropy_var.get()],
            "renderScale": render_scale_name_to_value[self.render_scale_var.get()],
            "shadowResolution": shadow_res_name_to_value[self.shadow_res_var.get()],
            "motionBlur": self.motion_blur_var.get(),
            "depthOfField": self.depth_of_field_var.get(),
            "bloom": self.bloom_var.get(),
            "disableCameraShake": self.no_camera_shake_var.get(),
            "hideTargetLines": self.hide_target_lines_var.get(),
            "damageNumberScale": damage_number_scale,
            "damageNumberOpacity": damage_number_opacity,
            "damageTextureScale": damage_texture_scale,
            "damageTextureOpacity": damage_texture_opacity,
            "hideUi": self.hide_ui_var.get(),
            "hideCabinetHud": self.hide_cabinet_hud_var.get(),
            "hideUiKey": resolve_key(self.hide_ui_key_var.get()),
        })
        self.config_data["graphics"] = self.graphics_data
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

        # [io4] mode is the actual switch the game reads to decide which
        # scheme is live - scooby.exe writes this same key. Configuring the
        # Controller (XInput) tab below does nothing at all in-game unless
        # this is also set to "xinput" (the game defaults to "keyboard" if
        # this key is missing, which is the ini's own out-of-the-box state).
        mode_frame = ttk.Frame(self)
        mode_frame.pack(fill="x", pady=(0, 10))
        ttk.Label(mode_frame, text="Active input mode:").pack(side="left")
        current_mode = get_ini_value(self.ini_text, "io4", "mode", "keyboard").strip().lower()
        self.input_mode_var = tk.StringVar(value="Controller (XInput)" if current_mode == "xinput" else "Keyboard")
        mode_combo = ttk.Combobox(mode_frame, textvariable=self.input_mode_var,
                                   values=["Keyboard", "Controller (XInput)"], state="readonly", width=20)
        mode_combo.pack(side="left", padx=(6, 10))
        mode_combo.bind("<<ComboboxSelected>>", self._on_mode_changed)
        ttk.Label(mode_frame, text="This is what actually switches which scheme the game listens to.",
                  foreground="gray").pack(side="left")

        self.notebook = notebook = ttk.Notebook(self)
        notebook.pack(fill="both", expand=True)
        kb_frame = ttk.Frame(notebook, padding=12)
        xi_frame = ttk.Frame(notebook, padding=12)
        notebook.add(kb_frame, text="Keyboard")
        notebook.add(xi_frame, text="Controller (XInput)")
        notebook.select(1 if current_mode == "xinput" else 0)

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
        if HAVE_EVDEV:
            ttk.Button(xi_frame, text="Vibrate to test", width=14,
                       command=self._identify_controller).grid(row=row, column=2, sticky="w", padx=(6, 0))
        row += 1
        if HAVE_EVDEV:
            self.identify_status_var = tk.StringVar(value="")
            ttk.Label(xi_frame, textvariable=self.identify_status_var, foreground="gray", wraplength=440).grid(
                row=row, column=0, columnspan=3, sticky="w")
            row += 1
        ttk.Label(xi_frame, text="Movement:", width=20).grid(row=row, column=0, sticky="w", pady=3)
        movement_current = int(get_ini_value(self.ini_text, "xinput", "movement", "0") or 0)
        self.movement_var = tk.StringVar(value=MOVEMENT_VALUE_TO_NAME.get(movement_current, "Left Stick"))
        ttk.Combobox(xi_frame, textvariable=self.movement_var, values=[n for n, _ in MOVEMENT_CHOICES],
                     state="readonly", width=14).grid(row=row, column=1, sticky="w")
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

    def _on_mode_changed(self, _event=None):
        self.notebook.select(1 if self.input_mode_var.get().startswith("Controller") else 0)

    def _capture(self, var):
        dialog = CaptureDialog(self.winfo_toplevel())
        self.wait_window(dialog)
        if dialog.result is not None:
            var.set(XINPUT_VALUE_TO_NAME.get(dialog.result, f"0x{dialog.result:X}"))

    def _identify_controller(self):
        devices = _ff_devices()
        try:
            index = int(self.controller_index_var.get())
        except ValueError:
            index = 0
        if not devices:
            self.identify_status_var.set("No vibration-capable controller detected via evdev.")
            return
        if index >= len(devices):
            self.identify_status_var.set(
                f"Only {len(devices)} controller(s) with vibration support detected - "
                f"controller number {index} isn't one of them.")
            return
        dev = devices[index]
        try:
            effect_id = _rumble_device(dev)
        except OSError as exc:
            self.identify_status_var.set(f"Could not vibrate {dev.name}: {exc}")
            return
        self.identify_status_var.set(
            f"Vibrating: {dev.name} (slot {index} of {len(devices)} detected) - best-effort match only, "
            f"Wine's own controller numbering may not match this order.")
        self.after(700, lambda: self._cleanup_rumble(dev, effect_id))

    @staticmethod
    def _cleanup_rumble(dev, effect_id):
        try:
            dev.erase_effect(effect_id)
        except OSError:
            pass

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
        movement_value = {n: v for n, v in MOVEMENT_CHOICES}[self.movement_var.get()]
        text = set_ini_value(text, "xinput", "movement", str(movement_value))

        # segatools.ini's own [io4] mode - matches scooby's own behavior
        # (ControlSettingsView.cs writes this on every save). DualSense isn't
        # offered by this GUI, so always leave it explicitly off.
        #
        # This alone does NOT control the real launch, though:
        # fgo-launcher.sh copies this file into a *runtime* copy and then
        # unconditionally overwrites [io4] mode again from fgo-launcher.json's
        # own "inputMode" field (defaulting to "xinput" if that field is ever
        # missing/invalid - see read_launcher_config.py and the `set_ini io4
        # mode "$effective_input_mode"` line in fgo-launcher.sh). Writing both
        # keeps segatools.ini correct for anything that reads it directly
        # (e.g. scooby.exe) while actually taking effect for a real launch.
        mode = "xinput" if self.input_mode_var.get().startswith("Controller") else "keyboard"
        text = set_ini_value(text, "io4", "mode", mode)
        text = set_ini_value(text, "dualsense", "enabled", "0")

        launcher_config = load_launcher_json()
        launcher_config["inputMode"] = mode
        save_launcher_json(launcher_config)

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
    """Mirrors scooby's own "Cards and Deck" > Deck page (MainWindow.xaml/.cs
    in a scooby source checkout): Show/Sort/Owned-only filters, List/Icons
    views, and Loadouts (save/load/delete/export/import), all reading and
    writing the exact same files scooby.exe does. The one deliberate
    difference: card selection is click-to-add + double-click for a
    quantity/variant dialog rather than mouse drag-and-drop (Tkinter has no
    native drag-and-drop, and this gets the same outcome without it) - deck
    reordering isn't supported for the same reason (order isn't meaningful
    to deck.json anyway).

    The card catalog is NOT limited to what fgo_account.py's owned_cards
    reports (that would leave "All Cards"/unowned browsing impossible) - it
    starts from the game's own DEVICE/print/FGO11_AllServants/library-
    manifest.json (load_card_catalog(), the same file fgo_account.py's own
    load_card_manifest_by_id() reads), then overlays the account's real
    owned counts on top. Cards sharing one internal ID (a character/CE's
    different art variants) are grouped into one entity, same as scooby's
    own CardStack.BuildEntities - nothing about specific cards/IDs is
    hardcoded here."""

    PAGE_SIZE = 48
    THUMB_SIZE = (72, 111)
    LIST_THUMB_SIZE = (56, 86)
    MAX_DECK_SIZE = 30

    def __init__(self, parent):
        super().__init__(parent, padding=12)
        self.thumb_cache = {}  # file_name -> ImageTk.PhotoImage
        self.all_cards = {}  # tc_id -> card dict
        self.entities = []  # [{"card": representative, "count": int, "variants": [card, ...]}]
        self.filtered_entities = []
        self.page = 0
        self.selected = {}  # file_name -> {"card": card_dict, "qty": IntVar}
        self.cards_path = None
        self._cards_path_override = None
        self._click_after_id = None
        self._game_version = ""
        self._cache_queue = []

        if not HAVE_PIL:
            ttk.Label(self, text="Pillow (python3-Pillow) is required for the deck editor's card artwork - install it and restart.",
                      foreground="red", wraplength=500).pack(padx=8, pady=8)
            return

        self._card_type_name_to_value = {n: v for n, v in CARD_TYPE_CHOICES}
        self._card_sort_name_to_value = {n: v for n, v in CARD_SORT_CHOICES}

        path_row = ttk.Frame(self)
        path_row.pack(fill="x", pady=(0, 8))
        ttk.Label(path_row, text="Card Folder:").pack(side="left")
        self.cards_path_var = tk.StringVar()
        ttk.Entry(path_row, textvariable=self.cards_path_var).pack(side="left", fill="x", expand=True, padx=(6, 6))
        ttk.Button(path_row, text="Reload", command=self._reload_from_path).pack(side="left")

        ttk.Label(self, text="Click a card to add it, or double-click one to pick its art and quantity.",
                  foreground="gray").pack(anchor="w", pady=(0, 6))

        toolbar = ttk.Frame(self)
        toolbar.pack(fill="x")
        ttk.Label(toolbar, text="Show").pack(side="left")
        self.show_var = tk.StringVar(value="All Cards")
        ttk.Combobox(toolbar, textvariable=self.show_var, values=[n for n, _ in CARD_TYPE_CHOICES],
                     state="readonly", width=14).pack(side="left", padx=(4, 12))
        self.show_var.trace_add("write", lambda *_: self._apply_filter())
        ttk.Label(toolbar, text="Sort").pack(side="left")
        self.sort_var = tk.StringVar(value="Folder order")
        ttk.Combobox(toolbar, textvariable=self.sort_var, values=[n for n, _ in CARD_SORT_CHOICES],
                     state="readonly", width=12).pack(side="left", padx=(4, 12))
        self.sort_var.trace_add("write", lambda *_: self._apply_filter())
        self.owned_only_var = tk.BooleanVar(value=False)
        ttk.Checkbutton(toolbar, text="Owned cards only", variable=self.owned_only_var,
                        command=self._apply_filter).pack(side="left", padx=(0, 16))
        self._cache_button = ttk.Button(toolbar, text="Cache Thumbnails", command=self._build_thumbnail_cache)
        self._cache_button.pack(side="left")
        ttk.Label(toolbar, text="View").pack(side="left", padx=(16, 4))
        self.view_mode = tk.StringVar(value="Icons")
        ttk.Radiobutton(toolbar, text="List", value="List", variable=self.view_mode, style="Toolbutton",
                         command=self._on_view_mode_changed).pack(side="left")
        ttk.Radiobutton(toolbar, text="Icons", value="Icons", variable=self.view_mode, style="Toolbutton",
                         command=self._on_view_mode_changed).pack(side="left")

        self.summary_var = tk.StringVar(value="")
        ttk.Label(self, textvariable=self.summary_var, foreground="gray", wraplength=780).pack(anchor="w", pady=(6, 4))

        search_row = ttk.Frame(self)
        search_row.pack(fill="x")
        ttk.Label(search_row, text="Search:").pack(side="left")
        self.search_var = tk.StringVar()
        self.search_var.trace_add("write", lambda *_: self._apply_filter())
        ttk.Entry(search_row, textvariable=self.search_var, width=30).pack(side="left", padx=(4, 12))
        self.page_label_var = tk.StringVar(value="")
        ttk.Label(search_row, textvariable=self.page_label_var).pack(side="left", padx=(12, 0))
        ttk.Button(search_row, text="< Prev", command=self._prev_page).pack(side="left", padx=(12, 0))
        ttk.Button(search_row, text="Next >", command=self._next_page).pack(side="left", padx=(4, 0))

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

        side = ttk.Frame(body, width=240)
        side.pack(side="left", fill="y", padx=(10, 0))
        self.deck_status_var = tk.StringVar(value="0 of 30 cards")
        ttk.Label(side, textvariable=self.deck_status_var, font=("", 10, "bold")).pack(anchor="w")
        ttk.Button(side, text="Clear Deck", command=self._clear_deck).pack(fill="x", pady=(2, 8))
        ttk.Label(side, text="Selected deck:").pack(anchor="w")
        self.selected_list = tk.Listbox(side, width=32, height=14)
        self.selected_list.pack(fill="both", expand=True)
        ttk.Button(side, text="Remove selected", command=self._remove_from_deck_list).pack(fill="x", pady=(4, 0))
        ttk.Button(side, text="Save Deck", command=self.save).pack(fill="x", pady=(4, 0))

        ttk.Separator(side, orient="horizontal").pack(fill="x", pady=10)
        ttk.Label(side, text="Loadouts:").pack(anchor="w")
        self.loadout_var = tk.StringVar()
        self.loadout_combo = ttk.Combobox(side, textvariable=self.loadout_var, state="readonly", width=28)
        self.loadout_combo.pack(fill="x", pady=(2, 4))
        loadout_row1 = ttk.Frame(side)
        loadout_row1.pack(fill="x")
        ttk.Button(loadout_row1, text="Save as", command=self._loadout_save).pack(side="left", expand=True, fill="x")
        ttk.Button(loadout_row1, text="Load", command=self._loadout_load).pack(side="left", expand=True, fill="x")
        ttk.Button(loadout_row1, text="Delete", command=self._loadout_delete).pack(side="left", expand=True, fill="x")
        loadout_row2 = ttk.Frame(side)
        loadout_row2.pack(fill="x", pady=(2, 0))
        ttk.Button(loadout_row2, text="Export", command=self._loadout_export).pack(side="left", expand=True, fill="x")
        ttk.Button(loadout_row2, text="Import", command=self._loadout_import).pack(side="left", expand=True, fill="x")
        open_folder_link = ttk.Label(side, text="Open folder", foreground="#3d8fd6", cursor="hand2")
        open_folder_link.pack(anchor="w", pady=(6, 0))
        open_folder_link.bind("<Button-1>", lambda e: self._loadout_open_folder())

        self.status_var = tk.StringVar(value="")
        ttk.Label(self, textvariable=self.status_var, foreground="gray", wraplength=780).pack(anchor="w", pady=(6, 0))

        self.reload()

    # --- loading / filtering -------------------------------------------------

    def _resolve_cards_path(self):
        if self._cards_path_override is not None:
            return self._cards_path_override
        try:
            deck = json.loads(deck_json_path().read_text(encoding="utf-8"))
            raw = deck.get("CardsPath") or ""
        except (OSError, json.JSONDecodeError):
            raw = ""
        if not raw:
            raw = "../DEVICE/print/FGO11_AllServants"
        return (install_root() / "App" / raw.replace("\\", "/")).resolve()

    def _reload_from_path(self):
        text = self.cards_path_var.get().strip()
        self._cards_path_override = Path(text).expanduser() if text else None
        self.thumb_cache.clear()
        self.reload()

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
        owned_cards = current.get("owned_cards", []) if current else []
        self.cards_path = self._resolve_cards_path()
        self.cards_path_var.set(str(self.cards_path))

        catalog = load_card_catalog()
        for card in owned_cards:
            catalog[card["tc_id"]] = card  # real owned data wins over the zero-count placeholder
        self.all_cards = catalog

        groups = {}
        for card in self.all_cards.values():
            key = TRANSLATIONS.internal_id(card)
            if not key:
                continue
            groups.setdefault(key, []).append(card)
        entities = []
        for variants in groups.values():
            variants.sort(key=lambda c: c["tc_id"])
            entities.append({"card": variants[0], "count": sum(v["count"] for v in variants), "variants": variants})
        self.entities = entities

        self.selected.clear()
        try:
            deck = json.loads(deck_json_path().read_text(encoding="utf-8"))
            selected_paths = deck.get("SelectedCards") or []
            selected_copies = deck.get("SelectedCardCopies") or []
            by_file = {c["file_name"]: c for c in self.all_cards.values()}
            for path, qty in zip(selected_paths, selected_copies):
                file_name = Path(path.replace("\\", "/")).name
                card = by_file.get(file_name)
                if card:
                    self.selected[file_name] = {"card": card, "qty": tk.IntVar(value=qty)}
        except (OSError, json.JSONDecodeError):
            pass

        self._game_version = load_launcher_json().get("gameVersion", "")
        self._refresh_loadouts()
        self._apply_filter()
        self._refresh_selected_list()
        who = current["master_name"] if current else "no account"
        self.status_var.set(f"Cards for {who}. Cards read from {self.cards_path}.")

    def _apply_filter(self):
        if not self.entities and not hasattr(self, "summary_var"):
            return  # HAVE_PIL was False - no widgets were built at all
        show_type = self._card_type_name_to_value.get(self.show_var.get(), 0)
        owned_only = self.owned_only_var.get()
        query = self.search_var.get().strip().lower()

        def matches(entity):
            card = entity["card"]
            if show_type and card["card_type_id"] != show_type:
                return False
            if owned_only and entity["count"] <= 0:
                return False
            if not query:
                return True
            name = self._display_name(card).lower()
            japanese = (TRANSLATIONS.japanese_name(card) or "").lower()
            internal_id = (TRANSLATIONS.internal_id(card) or "").lower()
            if query in name or query in japanese or query in internal_id:
                return True
            return any(query in v["file_name"].lower() or query in str(v["tc_id"]) for v in entity["variants"])

        filtered = [e for e in self.entities if matches(e)]
        sort_mode = self._card_sort_name_to_value.get(self.sort_var.get(), 0)
        if sort_mode == 1:  # Name
            filtered.sort(key=lambda e: self._display_name(e["card"]).lower())
        elif sort_mode == 2:  # Card number
            filtered.sort(key=lambda e: e["card"]["tc_id"])
        # sort_mode == 0 (Folder order): keep self.entities' own build order

        self.filtered_entities = filtered
        self.page = 0
        self._render_current_page()
        self._update_summary()

    def _update_summary(self):
        servant_total = sum(1 for e in self.entities if e["card"]["card_type_id"] == 1)
        ce_total = sum(1 for e in self.entities if e["card"]["card_type_id"] == 2)
        show_type = self._card_type_name_to_value.get(self.show_var.get(), 0)
        if show_type == 1:
            label = f"Servants {servant_total:,}"
        elif show_type == 2:
            label = f"Craft Essences {ce_total:,}"
        else:
            label = f"Servants {servant_total:,} / Craft Essences {ce_total:,}"
        shown = len(self.filtered_entities)
        self.summary_var.set(f"{label} - {shown:,} shown")
        if not self.all_cards:
            self.summary_var.set(f"No card images in {self.cards_path}. They come with the full package "
                                  "(DEVICE/print/FGO11_AllServants), not with any update - extract that "
                                  "package into the game folder again, then click Reload.")

    def _prev_page(self):
        if self.page > 0:
            self.page -= 1
            self._render_current_page()

    def _next_page(self):
        if (self.page + 1) * self.PAGE_SIZE < len(self.filtered_entities):
            self.page += 1
            self._render_current_page()

    def _on_view_mode_changed(self):
        self.page = 0
        self._render_current_page()

    # --- thumbnails ------------------------------------------------------

    def _thumbnail_cache_dir(self):
        return install_root() / "DEVICE" / "cache" / "card-thumbnails"

    def _cached_thumbnail_path(self, file_name):
        return self._thumbnail_cache_dir() / (Path(file_name).stem + ".jpg")

    def _thumbnail(self, card, size=None):
        file_name = card["file_name"]
        if not file_name:
            return None
        cache_key = (file_name, size or self.THUMB_SIZE)
        if cache_key in self.thumb_cache:
            return self.thumb_cache[cache_key]
        source = self.cards_path / file_name
        cached = self._cached_thumbnail_path(file_name)
        photo = None
        try:
            use_cache = cached.is_file() and cached.stat().st_mtime >= source.stat().st_mtime
            image = Image.open(cached if use_cache else source)
            image.thumbnail(size or self.THUMB_SIZE)
            photo = ImageTk.PhotoImage(image)
        except (OSError, ValueError):
            photo = None
        self.thumb_cache[cache_key] = photo
        return photo

    def _build_thumbnail_cache(self):
        files = sorted({c["file_name"] for c in self.all_cards.values() if c["file_name"]})
        if not files:
            return
        self._cache_queue = files
        self._cache_total = len(files)
        self._cache_done = 0
        self._cache_created = 0
        self._cache_failed = 0
        self._cache_button.state(["disabled"])
        self._cache_thumbnail_step()

    def _cache_thumbnail_step(self):
        chunk = 25
        cache_dir = self._thumbnail_cache_dir()
        cache_dir.mkdir(parents=True, exist_ok=True)
        for _ in range(chunk):
            if not self._cache_queue:
                break
            file_name = self._cache_queue.pop(0)
            self._cache_done += 1
            source = self.cards_path / file_name
            target = self._cached_thumbnail_path(file_name)
            try:
                if not (target.is_file() and target.stat().st_mtime >= source.stat().st_mtime):
                    image = Image.open(source)
                    image.thumbnail((160, 224))
                    image.convert("RGB").save(target, "JPEG", quality=84)
                    self._cache_created += 1
            except (OSError, ValueError):
                self._cache_failed += 1
        self._cache_button.configure(text=f"Caching {self._cache_done:,}/{self._cache_total:,}")
        if self._cache_queue:
            self.after(1, self._cache_thumbnail_step)
        else:
            label = (f"Cached +{self._cache_created:,}" if self._cache_failed == 0
                      else f"Done +{self._cache_created:,} / failed {self._cache_failed:,}")
            self._cache_button.configure(text=label)
            self._cache_button.state(["!disabled"])
            self.thumb_cache.clear()
            self._render_current_page()

    @staticmethod
    def _display_name(card):
        return TRANSLATIONS.english_name(card) or card["display_name"]

    # --- rendering ---------------------------------------------------------

    def _render_current_page(self):
        for child in self.grid_frame.winfo_children():
            child.destroy()
        start = self.page * self.PAGE_SIZE
        page_entities = self.filtered_entities[start:start + self.PAGE_SIZE]
        if self.view_mode.get() == "List":
            self._render_list(page_entities)
        else:
            self._render_icons(page_entities)
        total_pages = max(1, (len(self.filtered_entities) + self.PAGE_SIZE - 1) // self.PAGE_SIZE)
        self.page_label_var.set(f"Page {self.page + 1}/{total_pages}")

    def _is_entity_selected(self, entity):
        return any(v["file_name"] in self.selected for v in entity["variants"])

    def _render_icons(self, entities):
        columns = 6
        for index, entity in enumerate(entities):
            card = entity["card"]
            r, c = divmod(index, columns)
            is_selected = self._is_entity_selected(entity)
            cell = ttk.Frame(self.grid_frame, padding=4,
                              relief="solid" if is_selected else "flat",
                              borderwidth=2 if is_selected else 0)
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
                widget.bind("<Button-1>", lambda e, en=entity: self._on_click(en))
                widget.bind("<Double-Button-1>", lambda e, en=entity: self._on_double_click(en))

    def _render_list(self, entities):
        for entity in entities:
            card = entity["card"]
            is_selected = self._is_entity_selected(entity)
            row = ttk.Frame(self.grid_frame, padding=6,
                              relief="solid" if is_selected else "flat",
                              borderwidth=1 if is_selected else 0)
            row.pack(fill="x", pady=1)
            row.grid_columnconfigure(1, weight=1)
            photo = self._thumbnail(card, self.LIST_THUMB_SIZE)
            if photo is not None:
                thumb_label = tk.Label(row, image=photo, cursor="hand2")
                thumb_label.image = photo
            else:
                thumb_label = tk.Label(row, text="(no image)", width=9, height=5, cursor="hand2")
            thumb_label.grid(row=0, column=0, rowspan=3, padx=(0, 12))
            name = self._display_name(card)
            japanese = TRANSLATIONS.japanese_name(card)
            internal_id = TRANSLATIONS.internal_id(card) or "?"
            ttk.Label(row, text=name, font=("", 11, "bold")).grid(row=0, column=1, sticky="w")
            ttk.Label(row, text=japanese or "", foreground="gray").grid(row=1, column=1, sticky="w")
            ttk.Label(row, text=f"Internal ID {internal_id}", foreground="gray").grid(row=2, column=1, sticky="w")
            type_label = "Servant" if card["card_type_id"] == 1 else "Craft Essence"
            ttk.Label(row, text=f"{type_label} x{entity['count']}", font=("", 9, "bold")).grid(
                row=0, column=2, sticky="e", padx=(16, 0))
            ttk.Label(row, text=f"TC ID {card['tc_id']}", foreground="gray").grid(
                row=1, column=2, sticky="e", padx=(16, 0))
            for widget in (row, thumb_label):
                widget.bind("<Button-1>", lambda e, en=entity: self._on_click(en))
                widget.bind("<Double-Button-1>", lambda e, en=entity: self._on_double_click(en))

    # --- selection -----------------------------------------------------------

    def _on_click(self, entity):
        # A single click toggles selection, which rebuilds the whole page
        # (_render_current_page destroys every cell/row widget) - doing that
        # immediately would destroy the widget mid double-click, before Tk
        # ever gets to recognize the second click as one, so
        # <Double-Button-1> would never fire. Defer the toggle instead, and
        # let a real double-click (which cancels it) take over.
        if self._click_after_id is not None:
            self.after_cancel(self._click_after_id)
        self._click_after_id = self.after(250, lambda: self._commit_click(entity))

    def _on_double_click(self, entity):
        if self._click_after_id is not None:
            self.after_cancel(self._click_after_id)
            self._click_after_id = None
        self._open_detail(entity)

    def _commit_click(self, entity):
        self._click_after_id = None
        self._toggle_entity(entity)

    def _toggle_entity(self, entity):
        # Any selected variant counts as "this entity is in the deck" - a
        # plain click toggles the representative (lowest TC ID) variant off
        # entirely, or on at quantity 1; double-click (the full dialog) picks
        # a different variant or sets quantities per variant.
        if self._is_entity_selected(entity):
            for variant in entity["variants"]:
                self.selected.pop(variant["file_name"], None)
        else:
            if sum(e["qty"].get() for e in self.selected.values()) >= self.MAX_DECK_SIZE:
                self.status_var.set(f"Deck is full ({self.MAX_DECK_SIZE} cards) - remove something first.")
                return
            file_name = entity["card"]["file_name"]
            self.selected[file_name] = {"card": entity["card"], "qty": tk.IntVar(value=1)}
        self._render_current_page()
        self._refresh_selected_list()

    def _open_detail(self, entity):
        dialog = CardDetailDialog(self.winfo_toplevel(), entity["card"], entity["variants"], self.selected, self._thumbnail)
        self.wait_window(dialog)
        if dialog.changed:
            self._render_current_page()
            self._refresh_selected_list()

    def _refresh_selected_list(self):
        self.selected_list.delete(0, "end")
        for entry in self.selected.values():
            self.selected_list.insert("end", f"{entry['qty'].get()}x {self._display_name(entry['card'])[:28]}")
        total = sum(entry["qty"].get() for entry in self.selected.values())
        suffix = f" - FGO {self._game_version}" if self._game_version else ""
        self.deck_status_var.set(f"{total} of {self.MAX_DECK_SIZE} cards{suffix}")

    def _remove_from_deck_list(self):
        selection = self.selected_list.curselection()
        if not selection:
            return
        file_name = list(self.selected.keys())[selection[0]]
        del self.selected[file_name]
        self._render_current_page()
        self._refresh_selected_list()

    def _clear_deck(self):
        if not self.selected:
            return
        if not messagebox.askyesno("Clear Deck", "Remove all cards from the deck?"):
            return
        self.selected.clear()
        self._render_current_page()
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

    # --- loadouts (App/deck-loadouts/<name>.json) ---------------------------
    # Format matches scooby's own exactly ("fgoac-loadout" v1, file+copy
    # pairs, no paths) so loadouts saved by either tool load in the other.

    def _refresh_loadouts(self, select=None):
        folder = loadout_folder()
        names = sorted(p.stem for p in folder.glob("*.json")) if folder.is_dir() else []
        self.loadout_combo["values"] = names
        if select is not None and select in names:
            self.loadout_var.set(select)
        elif self.loadout_var.get() not in names:
            self.loadout_var.set("")

    def _loadout_save(self):
        if not self.selected:
            self.status_var.set("The deck is empty - nothing to save.")
            return
        name = simpledialog.askstring("Save loadout", "Name for this deck:",
                                       initialvalue=self.loadout_var.get(), parent=self.winfo_toplevel())
        if not name:
            return
        folder = loadout_folder()
        folder.mkdir(parents=True, exist_ok=True)
        target = folder / f"{name}.json"
        if target.exists() and not messagebox.askyesno("Save loadout", f'Replace the loadout "{name}"?'):
            return
        cards = [{"file": entry["card"]["file_name"], "copy": entry["qty"].get()} for entry in self.selected.values()]
        payload = {"format": "fgoac-loadout", "version": 1, "name": name, "cards": cards}
        try:
            target.write_text(json.dumps(payload, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        except OSError as exc:
            self.status_var.set(f"The loadout could not be saved: {exc}")
            return
        self._refresh_loadouts(select=name)
        self.status_var.set(f"Loadout saved: {name}. Export sends a copy to share.")

    @staticmethod
    def _looks_like_loadout(data):
        return isinstance(data, dict) and data.get("format") == "fgoac-loadout" and isinstance(data.get("cards"), list)

    def _apply_loadout_file(self, path):
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            self.status_var.set("That file is not a deck loadout.")
            return
        if not self._looks_like_loadout(data):
            self.status_var.set("That file is not a deck loadout.")
            return
        by_file = {c["file_name"]: c for c in self.all_cards.values()}
        new_selection = {}
        missing = 0
        for entry in data["cards"]:
            # basename only, same as scooby - a shared file cannot point outside the card folder
            file_name = Path(str(entry.get("file", ""))).name
            if not file_name:
                continue
            card = by_file.get(file_name)
            if not card:
                missing += 1
                continue
            try:
                qty = max(1, min(self.MAX_DECK_SIZE, int(entry.get("copy", 1))))
            except (TypeError, ValueError):
                qty = 1
            new_selection[file_name] = {"card": card, "qty": tk.IntVar(value=qty)}
        if not new_selection:
            self.status_var.set("None of that loadout's cards are in your card folder." if missing
                                 else "That loadout holds no cards.")
            return
        self.selected = new_selection
        self._render_current_page()
        self._refresh_selected_list()
        name = data.get("name") or path.stem
        suffix = (f"; {missing} not in your card folder were left out." if missing > 1
                  else "; 1 not in your card folder was left out." if missing == 1 else ".")
        self.status_var.set(f"Loadout loaded: {name} - {len(new_selection)} cards{suffix}")

    def _loadout_load(self):
        name = self.loadout_var.get()
        if not name:
            return
        self._apply_loadout_file(loadout_folder() / f"{name}.json")

    def _loadout_delete(self):
        name = self.loadout_var.get()
        if not name:
            return
        if not messagebox.askyesno("Delete loadout", f'Delete the loadout "{name}"?'):
            return
        (loadout_folder() / f"{name}.json").unlink(missing_ok=True)
        self._refresh_loadouts()
        self.status_var.set(f"Loadout deleted: {name}")

    def _loadout_export(self):
        name = self.loadout_var.get()
        if not name:
            self.status_var.set("Select a loadout to export, or Save as first.")
            return
        source = loadout_folder() / f"{name}.json"
        desktop = Path.home() / "Desktop"
        dest = filedialog.asksaveasfilename(
            title="Export loadout", initialfile=f"{name}.json", defaultextension=".json",
            initialdir=str(desktop if desktop.is_dir() else Path.home()), filetypes=[("Deck loadout", "*.json")])
        if not dest:
            return
        try:
            shutil.copyfile(source, dest)
        except OSError as exc:
            self.status_var.set(f"The loadout could not be exported: {exc}")
            return
        self.status_var.set(f"Exported: {Path(dest).name} - send it to anyone with the launcher; they add it with Import.")

    def _loadout_import(self):
        source = filedialog.askopenfilename(title="Import loadout", filetypes=[("Deck loadout", "*.json")])
        if not source:
            return
        try:
            data = json.loads(Path(source).read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            messagebox.showerror("Import", "That file is not a deck loadout. Pick a .json file that was "
                                            "exported from the Loadouts row.")
            return
        if not self._looks_like_loadout(data):
            messagebox.showerror("Import", "That file is not a deck loadout. Pick a .json file that was "
                                            "exported from the Loadouts row.")
            return
        name = data.get("name") or Path(source).stem
        folder = loadout_folder()
        folder.mkdir(parents=True, exist_ok=True)
        target = folder / f"{name}.json"
        try:
            shutil.copyfile(source, target)
        except OSError as exc:
            self.status_var.set(f"The loadout could not be imported: {exc}")
            return
        self._refresh_loadouts(select=name)
        self._apply_loadout_file(target)

    def _loadout_open_folder(self):
        folder = loadout_folder()
        folder.mkdir(parents=True, exist_ok=True)
        try:
            subprocess.Popen(["xdg-open", str(folder)])
        except OSError:
            messagebox.showinfo("Open folder", str(folder))


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
        except Exception as exc:
            messagebox.showerror("Could not launch", str(exc))
            return
        self.status_var.set("Launching...")
        self._shader_cache_dir = self._find_shader_cache_dir()
        self._shader_baseline = self._count_shader_files(self._shader_cache_dir)
        self._shader_last_count = self._shader_baseline
        self._shader_stable_ticks = 0
        self._shader_poll_ticks = 0
        self._poll_shader_progress()

    @staticmethod
    def _find_shader_cache_dir():
        # App/shader-cache-rN/ - the numeric suffix is tied to the game
        # version, so don't hardcode it. See fgo-launcher.sh's own comment on
        # this same directory for why it exists (persisted outside the
        # install via a symlink, to skip a cold shader recompile on a fresh
        # install).
        try:
            candidates = sorted(install_root().glob("App/shader-cache-r*"))
        except OSError:
            return None
        return candidates[0] if candidates else None

    @staticmethod
    def _count_shader_files(path):
        if path is None or not path.is_dir():
            return 0
        try:
            return sum(1 for entry in path.iterdir() if entry.is_file())
        except OSError:
            return 0

    def _poll_shader_progress(self):
        count = self._count_shader_files(self._shader_cache_dir)
        if self._shader_cache_dir is None:
            # The dir doesn't exist yet at all (very first launch ever, or
            # the symlink hasn't been recreated yet) - keep looking for it.
            self._shader_cache_dir = self._find_shader_cache_dir()
        new = count - self._shader_baseline
        self._shader_stable_ticks = self._shader_stable_ticks + 1 if count == self._shader_last_count else 0
        self._shader_last_count = count
        self._shader_poll_ticks += 1
        if new > 0:
            self.status_var.set(f"Launching - compiling shaders: {count} cached ({new} new this run)...")
        else:
            self.status_var.set(f"Launching... ({count} shaders already cached)")
        # Stop once the count's held steady for a few seconds (compile looks
        # done) or after a generous cap, so this doesn't poll forever if the
        # count never settles for some reason.
        if self._shader_stable_ticks >= 4 or self._shader_poll_ticks >= 180:
            suffix = f" ({new} new this run)" if new > 0 else ""
            self.status_var.set(f"Launched. {count} shaders cached{suffix}.")
            return
        self.after(1000, self._poll_shader_progress)


def main():
    app = App()
    app.mainloop()


if __name__ == "__main__":
    main()
