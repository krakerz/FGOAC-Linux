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
FPS_CHOICES = [("60", 60), ("120 (experimental)", 120)]
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


# --- Draw Rates (Server/artemis's own local summon-weight lottery) ---------
# Not a retail probability table - a local simulation knob ARTEMiS itself
# reads (Server/artemis/titles/fgo/summon_weights.py). One flat weighted
# pool across every eligible Servant/CE (base print only, no story-only or
# holo/alt-art entries) - not per-rarity buckets.
MAX_SUMMON_WEIGHT = 1_000_000


def summon_candidates_path():
    return install_root() / "Server" / "artemis" / "titles" / "fgo" / "data" / "summon_candidates.json"


def summon_weights_path():
    return install_root() / "Server" / "artemis" / "config" / "fgo_summon_weights.json"


def summon_presets_folder():
    # Matches scooby's own SummonSettingsWindow.PresetsFolder exactly - a
    # sibling of the live weights file, not under App/ like deck-loadouts.
    return summon_weights_path().parent / "summon-presets"


def load_summon_candidates():
    """The eligible summon pool - every non-"story"-category entry in
    summon_candidates.json (confirmed to match the real weights file's own
    entry count exactly: 1328 on this install). Returns card dicts in the
    same shape used everywhere else in this file (tc_id/card_type_id/
    servant_id/craft_essence_id/file_name/display_name), plus "rarity"."""
    try:
        document = json.loads(summon_candidates_path().read_text(encoding="utf-8-sig"))
    except (OSError, ValueError):
        return []
    candidates = []
    for row in document.get("cards", []):
        if not isinstance(row, dict) or row.get("category") == "story":
            continue
        try:
            tc_id = int(row["tc_id"])
            card_type_id = int(row["type"])
            entity_id = int(row["entity_id"])
        except (KeyError, TypeError, ValueError):
            continue
        candidates.append({
            "tc_id": tc_id,
            "count": 0,
            "card_type_id": card_type_id,
            "servant_id": entity_id if card_type_id == 1 else 0,
            "craft_essence_id": entity_id if card_type_id == 2 else 0,
            "display_name": str(row.get("name", f"Trading Card {tc_id}")),
            "file_name": str(row.get("file_name", "")),
            "rarity": int(row.get("rarity", 0)),
        })
    return candidates


def load_summon_weights(eligible_ids):
    """Mirrors summon_weights.py's own read_weights() defaulting rules
    exactly: an absent file means uniform weight 1 across the whole roster;
    once a file exists, any eligible id it doesn't mention is weight 0 (not
    1) - so a catalog update can only ever narrow an explicit configuration,
    never silently re-include something the file's own author left out.
    Falls back to the uniform default on a malformed file instead of
    raising - this is an editor, not the runtime lottery itself."""
    try:
        document = json.loads(summon_weights_path().read_text(encoding="utf-8-sig"))
    except (OSError, ValueError):
        return {tc_id: 1 for tc_id in eligible_ids}
    if not isinstance(document, dict) or document.get("version") != 1 or not isinstance(document.get("weights"), dict):
        return {tc_id: 1 for tc_id in eligible_ids}
    raw = document["weights"]
    weights = {}
    for tc_id in eligible_ids:
        try:
            weights[tc_id] = max(0, min(MAX_SUMMON_WEIGHT, int(raw.get(str(tc_id), 0))))
        except (TypeError, ValueError):
            weights[tc_id] = 0
    return weights


def save_summon_weights(weights):
    """Always writes every eligible id explicitly (never omits one at its
    default), so this file is never ambiguous about what it means - matches
    summon_weights.py's own "omitted id means zero" rule by simply never
    omitting anything ourselves."""
    if sum(weights.values()) <= 0:
        raise ValueError("At least one summon weight must be positive.")
    payload = {"version": 1, "weights": {str(tc_id): int(w) for tc_id, w in sorted(weights.items())}}
    path = summon_weights_path()
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")


# --- Audio volume (App/audio-volume.ini - scooby's AudioSettingsView) -----
# Applied live by the game itself while running - not something
# fgo-launcher.sh needs to inject at launch (confirmed: it has no
# volume-related code at all).
AUDIO_VOLUME_KEYS = ("bgm", "voice", "effects")


def audio_volume_path():
    return install_root() / "App" / "audio-volume.ini"


def load_audio_volume():
    path = audio_volume_path()
    try:
        text = path.read_text(encoding="utf-8")
    except OSError:
        text = ""
    values = {}
    for key in AUDIO_VOLUME_KEYS:
        try:
            values[key] = max(0, min(100, int(get_ini_value(text, "audio", key, "100"))))
        except (TypeError, ValueError):
            values[key] = 100
    return values


def save_audio_volume(values):
    path = audio_volume_path()
    lines = ["[audio]"] + [f"{key}={max(0, min(100, int(values[key])))}" for key in AUDIO_VOLUME_KEYS]
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


# --- Event visibility ("Banners" in scooby - an LTE story-event filter, not
# gacha pool/rate editing, which is the Draw Rates tab above) -------------
# Two independent pieces: a one-time source patch to two ARTEMiS Python
# files (adds the enabled_singularity_ids property/filter at all - without
# it, the filter list below does nothing), and the filter list itself,
# text-spliced into Server/artemis/config/fgo.yaml's own server: block.
EVENT_TOGGLE_MARKER = "fgo_event_toggles_v1"

EVENT_TOGGLE_IDS = [
    ("8008", "Gudaguda Honnoji Temple"), ("8010", "The Garden of Order - Revival"),
    ("8011", "600,000 Master Celebration"), ("8012", "Prisma Codes"),
    ("8013", "Material Exchange Ticket Celebration"), ("8014", "2nd Anniversary"),
    ("8015", "Da Vinci Acquisition Campaign - Revival II"),
    ("8016", "Chaldea Battle Summer League - Revival"), ("8017", "Summer Warrior Vacation Training"),
    ("8018", "Suzuka Gozen's Happy Merry Love Christmas!"),
    ("8019", "Elena's Christmas Present Recapture Operation - Revival"), ("8020", "Setanta's Trials"),
    ("8021", "Prisma Codes - Revival"), ("8022", "Lady Reines' Case Files"),
    ("8023", "Summer Warrior Vacation Training - Revival"),
    ("8025", "Servant Boot Camp! Mysterious Strict Instructor"),
    ("8027", "Lady Reines' Case Files - Revival"),
    ("8028", "Suzuka Gozen's Happy Merry Love Christmas! - Revival"),
    ("8029", "Santa Fran's Christmas Present!"), ("8030", "Setanta's Trials - Revival"),
    ("8031", "Invitation from BB"), ("8032", "Challenge to the Heights of Conquest!"),
    ("8033", "Dream Journey ~A Dreamland of Mystery and Terror~"),
    ("8034", "Servant Boot Camp! Mysterious Strict Instructor - Revival"),
    ("8035", "Chaldea Summer Garden! The Visitor from the Other Side"),
    ("8036", "Demon Beast Calamity Time Trial"),
    ("8038", "Freezing Order! Goddess of Ice and Snow Descending on a Moonlit Night"),
    ("8039", "Demon Beast Calamity Time Trial II"), ("8040", "Invitation from BB - Revival"),
    ("8041", "Lovely Duty! End of Year Struggles of the Maid of Love"),
    ("8042", "Santa Fran's Christmas Present! - Revival"),
    ("8043", "NFF Premium Tour Invitation! Heroic Spirit Traveling Tour"),
    ("8044", "Suzuka Gozen's Happy Merry Love Christmas! - Revival II"),
    ("8045", "Destiny-Dividing: The Red Beast and the Flame's Mission"),
    ("8046", "Demon Beast Calamity Time Trial V"), ("8047", "Setanta's Trials - Revival II"),
    ("8048", "Chaldea Battle Summer League - Revival II"),
    ("8049", "Santa Fran's Christmas Present! - Revival II"),
]

# (file, anchor_old, anchor_new) - byte-identical to scooby's own embedded
# FGOLocalPlatform.EventTogglePatch.json, confirmed (2026-09-29) to match
# this exact install's Server/artemis/titles/fgo/{config,index}.py verbatim.
EVENT_TOGGLE_PATCH = [
    ("config.py",
     "    @property\n    def loglevel(self) -> int:",
     "    @property\n    def enabled_singularity_ids(self) -> list | None:\n"
     "        # None (key absent) means no filter. A list, including an empty list,\n"
     "        # enables an allowlist for the event catalog and its derived banners.\n"
     "        value = CoreConfig.get_config_field(\n"
     "            self.__config, \"fgo\", \"server\", \"enabled_singularity_ids\", default=None\n"
     "        )\n"
     "        return value if isinstance(value, list) else None\n\n"
     "    @property\n    def loglevel(self) -> int:"),
    ("index.py",
     "        result = []\n        for priority, catalog_row in enumerate(\n            sorted(\n                (\n"
     "                    row\n                    for row in self._story_tlf_catalog()\n"
     "                    if int(row[\"tlf_scenario_id\"])\n                    not in extra_interlude_scenario_ids\n"
     "                ),\n                key=lambda row: int(row[\"tlf_scenario_id\"]),\n            ),\n"
     "            start=1,\n        ):\n            tlf_scenario_id = int(catalog_row[\"tlf_scenario_id\"])",
     "        # fgo_event_toggles_v1: None preserves original behavior exactly.\n"
     "        enabled_singularity_ids = self.game_cfg.server.enabled_singularity_ids\n"
     "        catalog_rows = list(self._story_tlf_catalog())\n        result = []\n"
     "        for priority, catalog_row in enumerate(\n            sorted(\n                (\n"
     "                    row\n                    for row in catalog_rows\n"
     "                    if int(row[\"tlf_scenario_id\"])\n                    not in extra_interlude_scenario_ids\n"
     "                    and (\n                        enabled_singularity_ids is None\n"
     "                        or int(row[\"singularity_id\"]) in enabled_singularity_ids\n                    )\n"
     "                ),\n                key=lambda row: int(row[\"tlf_scenario_id\"]),\n            ),\n"
     "            start=1,\n        ):\n            tlf_scenario_id = int(catalog_row[\"tlf_scenario_id\"])"),
]


def fgo_yaml_path():
    return install_root() / "Server" / "artemis" / "config" / "fgo.yaml"


def event_toggle_target(file_name):
    return install_root() / "Server" / "artemis" / "titles" / "fgo" / file_name


def event_toggle_status():
    """Whether the one-time source patch is already applied, per file."""
    status = {}
    for file_name, _, anchor_new in EVENT_TOGGLE_PATCH:
        path = event_toggle_target(file_name)
        try:
            text = path.read_text(encoding="utf-8")
        except OSError:
            status[file_name] = None  # file not found at all
            continue
        status[file_name] = (anchor_new in text) or (EVENT_TOGGLE_MARKER in text)
    return status


def apply_event_toggle_patch():
    """Applies EVENT_TOGGLE_PATCH to config.py/index.py, exactly matching
    scooby's own ApplyEventTogglePatch(): every edit is checked before any
    file is written (so a mismatch can't leave one file patched and not the
    other), each write keeps a .event-toggle.bak, and py_compile validates
    the result - restoring from that backup on a syntax error. Returns a
    list of human-readable result lines."""
    pending = []
    messages = []
    for file_name, anchor_old, anchor_new in EVENT_TOGGLE_PATCH:
        target = event_toggle_target(file_name)
        if not target.is_file():
            raise RuntimeError(f"{target} was not found. The server files may have been updated "
                                "since this was written.")
        text = target.read_text(encoding="utf-8")
        already_applied = (
            anchor_new in text or EVENT_TOGGLE_MARKER in text
            or (file_name == "config.py" and "def enabled_singularity_ids" in text)
        )
        if already_applied:
            messages.append(f"{target.name} already has the patch applied.")
            continue
        if text.count(anchor_old) != 1:
            raise RuntimeError(f"{target} does not match what this patch expects. The server files "
                                "may have been updated since this was written.")
        pending.append((target, text.replace(anchor_old, anchor_new, 1)))

    for target, updated_text in pending:
        backup = target.with_name(target.name + ".event-toggle.bak")
        shutil.copy2(target, backup)
        target.write_text(updated_text, encoding="utf-8")
        result = subprocess.run([fgo_python(), "-m", "py_compile", str(target)], capture_output=True, text=True)
        if result.returncode != 0:
            shutil.copy2(backup, target)
            raise RuntimeError(f"{target.name} failed validation and was restored from backup: "
                                f"{result.stderr.strip()}")
        messages.append(f"Applied to {target.name}")
    return messages or ["No event-toggle changes were needed."]


def load_enabled_singularity_ids():
    try:
        text = fgo_yaml_path().read_text(encoding="utf-8")
    except OSError:
        return set()
    match = re.search(r"^[ \t]*enabled_singularity_ids:[ \t]*\[([^\]]*)\]", text, re.MULTILINE)
    if not match:
        return set()
    return {m for m in re.findall(r"[0-9]+", match.group(1))}


def save_enabled_singularity_ids(ids):
    """Text-splices just the enabled_singularity_ids: key into fgo.yaml's
    own server: block, preserving every other line and the file's line
    ending style - mirrors scooby's own WriteEnabledSingularityIds() (never
    a full YAML round-trip, so nothing else in the file can be reformatted
    or reordered by accident)."""
    path = fgo_yaml_path()
    original = path.read_text(encoding="utf-8")
    line_ending = "\r\n" if "\r\n" in original else "\n"
    trailing_newline = original.endswith("\n")
    lines = original.replace("\r\n", "\n").split("\n")
    if trailing_newline:
        lines.pop()

    server_start = next((i for i, line in enumerate(lines) if line.rstrip() == "server:"), None)
    if server_start is None:
        raise RuntimeError("fgo.yaml has no server: block. The file may have been edited by hand.")

    insert_at = server_start + 1
    replace_from = replace_to = -1
    key_indent = 0
    for i in range(server_start + 1, len(lines)):
        trimmed = lines[i].lstrip()
        if not trimmed or trimmed.startswith("#"):
            continue
        indent = len(lines[i]) - len(trimmed)
        if indent == 0:
            break
        if replace_to == i and (indent > key_indent or (indent == key_indent and trimmed.startswith("- "))):
            replace_to = i + 1
        elif trimmed.startswith("enabled_singularity_ids:"):
            key_indent = indent
            replace_from = i
            replace_to = i + 1
        insert_at = i + 1

    if replace_from < 0:
        replace_from = replace_to = insert_at

    value_text = "null" if not ids else "[" + ", ".join(sorted(ids, key=int)) + "]"
    lines[replace_from:replace_to] = [f"  enabled_singularity_ids: {value_text}"]
    new_text = line_ending.join(lines) + (line_ending if trailing_newline else "")
    path.write_text(new_text, encoding="utf-8")


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


def _make_modal(dialog, parent):
    """transient() + grab_set(), safe against Tk's "grab failed: window not
    viewable" - grab_set() requires the window to already be mapped on
    screen, which isn't guaranteed right after Toplevel() on every window
    manager/timing (a double-click-triggered dialog can win the race against
    the first Map/Configure event). wait_visibility() blocks until it is."""
    dialog.transient(parent)
    dialog.wait_visibility()
    dialog.grab_set()


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
        _make_modal(self, parent)
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
        patch_buttons = ttk.Frame(self)
        patch_buttons.grid(row=row, column=0, columnspan=3, sticky="w", pady=(6, 0))
        ttk.Button(patch_buttons, text="Apply EN Patch", command=self._apply_en_patch).pack(side="left")
        ttk.Button(patch_buttons, text="Revert EN Patch", command=self._revert_en_patch).pack(side="left", padx=(8, 0))
        row += 1
        self.patch_status_var = tk.StringVar(value="")
        ttk.Label(self, textvariable=self.patch_status_var, foreground="gray", wraplength=460).grid(
            row=row, column=0, columnspan=3, sticky="w", pady=(4, 0))
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

    def _run_en_patch_script(self, extra_args, busy_text):
        script = Path(__file__).resolve().parent.parent / "apply-en-patch.sh"
        install_root_value = self.install_root_var.get().strip()
        if not install_root_value:
            self.patch_status_var.set("Set an install root above first.")
            return
        args = [str(script), "--install-root", install_root_value, "--non-interactive", *extra_args]
        if self.package_root_var.get().strip():
            args += ["--package-root", self.package_root_var.get().strip()]
        self.patch_status_var.set(busy_text)
        self.update_idletasks()
        try:
            result = subprocess.run(args, capture_output=True, text=True, timeout=120)
            tail = "\n".join((result.stdout + result.stderr).strip().splitlines()[-6:])
            self.patch_status_var.set(tail or ("Done." if result.returncode == 0 else f"Failed (exit {result.returncode})."))
        except Exception as exc:
            self.patch_status_var.set(f"Could not run apply-en-patch.sh: {exc}")

    def _apply_en_patch(self):
        self._run_en_patch_script([], "Applying the English patch...")

    def _revert_en_patch(self):
        if not messagebox.askyesno("Revert EN Patch",
                                    "Restore the install to how it was before the English patch was applied?\n\n"
                                    "This uses the most recent _en-patch-backup snapshot."):
            return
        self._run_en_patch_script(["--rollback"], "Reverting the English patch...")

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
    """monitorDevice is deliberately not exposed here. Not because it's
    fiddly to get right - confirmed 2026-09-29 it barely matters at all: a
    value naming a monitor that doesn't even exist on the real hardware
    (e.g. "\\\\.\\DISPLAY5" with only 3 real monitors connected) still
    launches and displays fine, on Wine or gamescope. fgo-launcher.sh only
    format-validates this field (matches \\\\.\\DISPLAYN), never checks it
    against a real enumerated display, and Wine's own GDI emulation falls
    back gracefully rather than failing when the named device isn't found.
    config_data still carries whatever's already on disk and save() never
    touches that key, so it round-trips untouched regardless."""

    def __init__(self, parent):
        super().__init__(parent, padding=16)
        self.config_data = load_launcher_json()
        self.graphics_data = self.config_data.setdefault("graphics", {})

        notebook = ttk.Notebook(self)
        notebook.pack(fill="both", expand=True)
        basic = ttk.Frame(notebook, padding=12)
        advanced = ttk.Frame(notebook, padding=12)
        audio = ttk.Frame(notebook, padding=16)
        notebook.add(basic, text="Basic")
        notebook.add(advanced, text="Advanced Graphics")
        notebook.add(audio, text="Audio")

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
        # 120 needs both targetFps=120 and FGO_UNLOCK_HIGH_FPS=1 (fgo.env) -
        # anything else actually runs at 60, so show 60.
        unlocked = get_env_value(read_env_file(), "FGO_UNLOCK_HIGH_FPS") == "1"
        current_fps = 120 if unlocked and self.config_data.get("targetFps") == 120 else 60
        self.fps_var = tk.StringVar(value={v: n for n, v in FPS_CHOICES}[current_fps])
        ttk.Combobox(basic, textvariable=self.fps_var, values=[n for n, _ in FPS_CHOICES],
                     state="readonly", width=20).grid(row=row, column=1, columnspan=3, sticky="w")
        row += 1
        ttk.Label(basic, text="120 loads a one-byte-patched copy of fgohook.dll (the original is untouched). "
                              "Experimental: runs the GPU much harder, and menus/touch may misbehave.",
                  foreground="gray", wraplength=520).grid(row=row, column=0, columnspan=4, sticky="w")
        row += 1

        ttk.Separator(basic, orient="horizontal").grid(row=row, column=0, columnspan=4, sticky="ew", pady=12)
        row += 1
        ttk.Label(basic, text="Gamescope (nested compositor)", font=("", 10, "bold")).grid(
            row=row, column=0, columnspan=4, sticky="w")
        row += 1
        ttk.Label(basic, text="Windowed and fullscreen both work, FSR included. Windowed mode uses "
                              "gamescope's SDL backend over X11 automatically (the default Wayland "
                              "backend freezes the game after one frame in a window).",
                  foreground="gray", wraplength=520).grid(row=row, column=0, columnspan=4, sticky="w", pady=(2, 4))
        row += 1
        # Stored in fgo.env, not fgo-launcher.json: fgo-launcher.sh reads these
        # FGO_GAMESCOPE_* keys from there, and fgo.env overrides the environment.
        env_text = read_env_file()
        self.gamescope_var = tk.BooleanVar(value=get_env_value(env_text, "FGO_GAMESCOPE") == "1")
        ttk.Checkbutton(basic, text="Run inside gamescope", variable=self.gamescope_var,
                        command=self._on_gamescope_toggled).grid(row=row, column=0, columnspan=2, sticky="w", pady=(4, 0))
        self.gamescope_fullscreen_var = tk.BooleanVar(
            value=get_env_value(env_text, "FGO_GAMESCOPE_FULLSCREEN") == "1")
        ttk.Checkbutton(basic, text="Fullscreen",
                        variable=self.gamescope_fullscreen_var).grid(
            row=row, column=2, columnspan=2, sticky="w", pady=(4, 0))
        row += 1

        self.gamescope_fsr_var = tk.BooleanVar(value=get_env_value(env_text, "FGO_GAMESCOPE_FSR") == "1")
        self.fsr_check = ttk.Checkbutton(basic, text="Upscale with AMD FSR", variable=self.gamescope_fsr_var,
                                          command=self._on_gamescope_toggled)
        self.fsr_check.grid(row=row, column=0, columnspan=2, sticky="w")
        ttk.Label(basic, text="Sharpness (0=sharpest, 20=softest):").grid(row=row, column=2, sticky="w")
        row += 1
        self.fsr_sharpness_var = tk.StringVar(value=get_env_value(env_text, "FGO_GAMESCOPE_SHARPNESS", "5") or "5")
        self.fsr_sharpness_entry = ttk.Entry(basic, textvariable=self.fsr_sharpness_var, width=6)
        self.fsr_sharpness_entry.grid(row=row - 1, column=3, sticky="w")

        ttk.Label(basic, text="Render at (game's own resolution, above) - upscale to:").grid(
            row=row, column=0, columnspan=4, sticky="w", pady=(6, 0))
        row += 1
        self.gamescope_output_width_var = tk.StringVar(value=get_env_value(env_text, "FGO_GAMESCOPE_OUTPUT_WIDTH"))
        self.gamescope_output_height_var = tk.StringVar(value=get_env_value(env_text, "FGO_GAMESCOPE_OUTPUT_HEIGHT"))
        self.gamescope_output_width_entry = ttk.Entry(basic, textvariable=self.gamescope_output_width_var, width=8)
        self.gamescope_output_width_entry.grid(row=row, column=0, sticky="w")
        ttk.Label(basic, text="x").grid(row=row, column=1)
        self.gamescope_output_height_entry = ttk.Entry(basic, textvariable=self.gamescope_output_height_var, width=8)
        self.gamescope_output_height_entry.grid(row=row, column=2, sticky="w")
        ttk.Label(basic, text="(blank = same as Resolution, no upscaling)", foreground="gray").grid(
            row=row, column=3, sticky="w")
        row += 1

        self._on_gamescope_toggled()

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

        # App/audio-volume.ini - a separate file scooby's own
        # AudioSettingsView reads/writes, applied live by the running game
        # (not something fgo-launcher.sh needs to inject at launch).
        audio_values = load_audio_volume()
        self.volume_vars = {}
        arow = 0
        ttk.Label(audio, text="Applied live while the game is running.", foreground="gray").grid(
            row=arow, column=0, columnspan=3, sticky="w", pady=(0, 12))
        arow += 1
        for label, key in (("Music (BGM):", "bgm"), ("Voice:", "voice"), ("Sound Effects:", "effects")):
            ttk.Label(audio, text=label, width=16).grid(row=arow, column=0, sticky="w", pady=6)
            # ttk.Scale reports continuous float positions (no "resolution"
            # snapping like classic tk.Scale) - an IntVar.get() would raise
            # TclError the first time the scale lands on a non-integer value.
            var = tk.DoubleVar(value=audio_values[key])
            self.volume_vars[key] = var
            scale = ttk.Scale(audio, from_=0, to=100, orient="horizontal", variable=var, length=260)
            scale.grid(row=arow, column=1, sticky="w")
            value_label = ttk.Label(audio, width=4)
            value_label.grid(row=arow, column=2, sticky="w", padx=(8, 0))

            def update_label(v, lbl=value_label, var=var):
                lbl.configure(text=str(int(round(var.get()))))

            var.trace_add("write", lambda *_a, u=update_label: u(None))
            update_label(None)
            arow += 1
        audio_buttons = ttk.Frame(audio)
        audio_buttons.grid(row=arow, column=0, columnspan=3, sticky="w", pady=(12, 0))
        ttk.Button(audio_buttons, text="Mute All", command=lambda: self._set_all_volume(0)).pack(side="left")
        ttk.Button(audio_buttons, text="Restore Defaults", command=lambda: self._set_all_volume(100)).pack(
            side="left", padx=(8, 0))

    def _set_all_volume(self, value):
        for var in self.volume_vars.values():
            var.set(value)

    def validate(self):
        try:
            width = int(self.width_var.get())
            height = int(self.height_var.get())
        except ValueError:
            raise ValueError("Resolution must be whole numbers.")
        if not (480 <= width <= 7680) or not (480 <= height <= 7680):
            raise ValueError("Resolution must be between 480 and 7680 on each side.")
        fps = dict(FPS_CHOICES)[self.fps_var.get()]

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

    def _gamescope_env_values(self):
        output_width = self.gamescope_output_width_var.get().strip()
        output_height = self.gamescope_output_height_var.get().strip()
        if bool(output_width) != bool(output_height):
            raise ValueError("Gamescope upscale size needs both width and height, or neither.")
        if output_width:
            try:
                ok = 480 <= int(output_width) <= 7680 and 480 <= int(output_height) <= 7680
            except ValueError:
                ok = False
            if not ok:
                raise ValueError("Gamescope upscale size must be whole numbers between 480 and 7680.")
        sharpness = self.fsr_sharpness_var.get().strip() or "5"
        try:
            if not 0 <= int(sharpness) <= 20:
                raise ValueError
        except ValueError:
            raise ValueError("FSR sharpness must be a whole number from 0 to 20.")
        flag = lambda var: "1" if var.get() else "0"
        return {
            "FGO_GAMESCOPE": flag(self.gamescope_var),
            "FGO_GAMESCOPE_FULLSCREEN": flag(self.gamescope_fullscreen_var),
            "FGO_GAMESCOPE_FSR": flag(self.gamescope_fsr_var),
            "FGO_GAMESCOPE_SHARPNESS": sharpness,
            "FGO_GAMESCOPE_OUTPUT_WIDTH": output_width,
            "FGO_GAMESCOPE_OUTPUT_HEIGHT": output_height,
        }

    def save(self):
        width, height, fps, damage = self.validate()
        gamescope_env = self._gamescope_env_values()
        gamescope_env["FGO_UNLOCK_HIGH_FPS"] = "1" if fps > 60 else "0"
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
        save_audio_volume({key: int(round(var.get())) for key, var in self.volume_vars.items()})
        set_env_values(gamescope_env)

    def _on_gamescope_toggled(self):
        gamescope_on = self.gamescope_var.get()
        state = "normal" if gamescope_on else "disabled"
        self.fsr_check.configure(state=state)
        self.gamescope_output_width_entry.configure(state=state)
        self.gamescope_output_height_entry.configure(state=state)
        fsr_state = "normal" if (gamescope_on and self.gamescope_fsr_var.get()) else "disabled"
        self.fsr_sharpness_entry.configure(state=fsr_state)

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
        row += 1

        ttk.Separator(self, orient="horizontal").grid(row=row, column=0, columnspan=2, sticky="ew", pady=10)
        row += 1
        ttk.Label(self, text="Local server process (ALL.Net/billing/AimeDB) - separate from the game "
                              "itself. fgo-launcher.sh starts it automatically before Play if configured "
                              "to, but you can also control it here directly (e.g. to restart it after "
                              "changing Draw Rates/Banners settings, without relaunching the game).",
                  foreground="gray", wraplength=420).grid(row=row, column=0, columnspan=2, sticky="w")
        row += 1
        server_buttons = ttk.Frame(self)
        server_buttons.grid(row=row, column=0, columnspan=2, sticky="w", pady=(6, 0))
        ttk.Button(server_buttons, text="Start Server", command=self._start_server).pack(side="left")
        ttk.Button(server_buttons, text="Stop Server", command=self._stop_server).pack(side="left", padx=(6, 0))
        ttk.Button(server_buttons, text="Restart Server", command=self._restart_server).pack(side="left", padx=(6, 0))
        row += 1
        self.server_status_var = tk.StringVar(value="")
        ttk.Label(self, textvariable=self.server_status_var, foreground="gray", wraplength=420).grid(
            row=row, column=0, columnspan=2, sticky="w", pady=(4, 0))

    def _run_server_script(self, script_name, busy_text, timeout=60):
        script = Path(__file__).resolve().parent.parent / script_name
        self.server_status_var.set(busy_text)
        self.update_idletasks()
        try:
            result = subprocess.run([str(script)], capture_output=True, text=True, timeout=timeout)
            tail = "\n".join((result.stdout + result.stderr).strip().splitlines()[-6:])
            self.server_status_var.set(tail or ("Done." if result.returncode == 0 else f"Failed (exit {result.returncode})."))
        except Exception as exc:
            self.server_status_var.set(f"Could not run {script_name}: {exc}")

    def _start_server(self):
        self._run_server_script("start-fgo-local-server.sh", "Starting the local server...")

    def _stop_server(self):
        self._run_server_script("stop-fgo-local-server.sh", "Stopping the local server...", timeout=20)

    def _restart_server(self):
        self._run_server_script("stop-fgo-local-server.sh", "Restarting: stopping first...", timeout=20)
        self._run_server_script("start-fgo-local-server.sh", "Restarting: starting...")

    def save(self):
        ports = {}
        for key, var in (("http", self.http_var), ("billing", self.billing_var),
                          ("aime", self.aime_var), ("database", self.database_var)):
            try:
                ports[key] = int(var.get())
            except ValueError:
                raise ValueError(f"{key} port must be a whole number.")
        host = self.host_var.get().strip()
        # `apply` refuses while the server is running, and the main Save button
        # saves every tab - skip it when nothing here changed, so saving e.g. audio
        # mid-game works.
        current = run_server_tool("show")
        unchanged = str(current.get("host", "auto")) == host and all(
            int(current.get(key, -1)) == value for key, value in ports.items())
        if not unchanged:
            run_server_tool("apply", "--host", host,
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
        _make_modal(self, parent)

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
        _make_modal(self, parent)

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

    def __init__(self, parent, card, variants, selected, thumbnail_fn, max_addable=30):
        super().__init__(parent)
        self.selected = selected
        self.changed = False
        self.qty_vars = {}
        self.max_addable = max_addable
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

        ttk.Label(self, text=f"{self.max_addable} slot(s) left in the deck.", foreground="gray").pack(
            anchor="w", padx=12, pady=(0, 4))

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
            # Each row is one physical/virtual card file - at most 1 of any
            # single exact variant ever goes in the deck (this matches
            # scooby's own CardVariantsWindow.Choice.Maximum: it's always
            # min(remaining deck slots, 1), never tied to how many spare
            # copies the account owns - "Owned x12" just means spares/trade
            # fodder, not stackable deck copies of the identical card. Not
            # gated on ownership at all either, since scooby itself lets you
            # plan a deck with any card in the roster - see the module
            # docstring's note on this exact point.
            row_max = max(0, min(self.max_addable, 1))
            ttk.Spinbox(table, from_=0, to=max(row_max, current_qty), textvariable=qty_var, width=6).grid(
                row=row, column=3, padx=6)

        self.error_var = tk.StringVar(value="")
        ttk.Label(self, textvariable=self.error_var, foreground="#c0392b", wraplength=440).pack(
            anchor="w", padx=12, pady=(4, 0))

        buttons = ttk.Frame(self, padding=12)
        buttons.pack(fill="x")
        ttk.Button(buttons, text="Cancel", command=self.destroy).pack(side="right")
        ttk.Button(buttons, text="Add Selected Quantities", command=self._apply).pack(side="right", padx=(0, 8))
        _make_modal(self, parent)

    def _apply(self):
        # Matches scooby's own Add_OnClick: the total added/kept across this
        # dialog's own rows can't exceed the deck slots that were free when
        # it opened (other cards elsewhere in the deck aren't touched here).
        new_total = sum(qty_var.get() for qty_var, _ in self.qty_vars.values())
        if new_total > self.max_addable:
            self.error_var.set(f"Choose at most {self.max_addable} card(s) here - {new_total} selected.")
            return
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
    ICON_CELL_WIDTH = 140  # measured real cell reqwidth (name_label's width=16 dominates, not the thumbnail)
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
        self._grid_window = self.grid_canvas.create_window((0, 0), window=self.grid_frame, anchor="nw")
        self.grid_frame.bind("<Configure>", lambda e: self.grid_canvas.configure(scrollregion=self.grid_canvas.bbox("all")))
        self._icon_columns = 6
        self.grid_canvas.bind("<Configure>", self._on_grid_canvas_resize)

        # Scrollable, not a plain fixed-height Frame - this side panel (deck
        # status/list + Loadouts row) is tall enough that a plain pack() cuts
        # its bottom buttons off below the window edge on a lot of window
        # sizes; a canvas+scrollbar guarantees everything's reachable
        # regardless of how short the window ends up.
        side_container = ttk.Frame(body, width=250)
        side_container.pack(side="left", fill="y", padx=(10, 0))
        side_container.pack_propagate(False)
        side_canvas = tk.Canvas(side_container, highlightthickness=0, width=232)
        side_scroll = ttk.Scrollbar(side_container, orient="vertical", command=side_canvas.yview)
        side_canvas.configure(yscrollcommand=side_scroll.set)
        side_scroll.pack(side="right", fill="y")
        side_canvas.pack(side="left", fill="both", expand=True)
        side = ttk.Frame(side_canvas)
        side_canvas.create_window((0, 0), window=side, anchor="nw", width=232)
        side.bind("<Configure>", lambda e: side_canvas.configure(scrollregion=side_canvas.bbox("all")))
        self.deck_status_var = tk.StringVar(value="0 of 30 cards")
        ttk.Label(side, textvariable=self.deck_status_var, font=("", 10, "bold")).pack(anchor="w")
        ttk.Button(side, text="Clear Deck", command=self._clear_deck).pack(fill="x", pady=(2, 8))
        ttk.Label(side, text="Selected deck:").pack(anchor="w")
        self.selected_list = tk.Listbox(side, width=30, height=10)
        self.selected_list.pack(fill="x")
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

    def _on_grid_canvas_resize(self, event):
        # The icon grid previously hardcoded 6 columns regardless of the
        # window's actual width, so on anything narrower than that it just
        # clipped the rightmost column(s) at the window edge with no way to
        # scroll to them (the canvas only scrolls vertically). Recomputed
        # from the canvas's real width instead, same idea as scooby's own
        # UpdateCardItemsSource (Max(1, Floor(ActualWidth / cellWidth))).
        self.grid_canvas.itemconfigure(self._grid_window, width=event.width)
        columns = max(1, event.width // self.ICON_CELL_WIDTH)
        if columns != self._icon_columns:
            self._icon_columns = columns
            if self.view_mode.get() != "List":
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
        columns = self._icon_columns
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
        # Matches scooby's own CardVariantsWindow: "slots" is the deck's
        # remaining capacity computed once at open time from the *whole*
        # current deck (including this entity's own already-selected
        # variants, if any) - not just the deck size minus this entity.
        current_total = sum(e["qty"].get() for e in self.selected.values())
        max_addable = max(0, self.MAX_DECK_SIZE - current_total)
        dialog = CardDetailDialog(self.winfo_toplevel(), entity["card"], entity["variants"], self.selected,
                                   self._thumbnail, max_addable=max_addable)
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
        # Forward slashes, not backslashes - Win32 (and so Wine) accepts "/"
        # in a path everywhere, but the ARTEMIS server itself is native Linux
        # Python: its own _load_card_catalog() does os.path.join/isabs on
        # this exact same CardsPath string, and on POSIX a backslash is just
        # an ordinary filename character, not a separator - a "..\DEVICE\..."
        # value resolves to one bogus nonexistent path component. That silently
        # empties the server's whole Servant catalog (caught by a bare
        # try/except there), so it can never recognize ANY Servant tc_id -
        # while Craft Essences still work, since their validation path reads
        # a fixed master file that doesn't go through CardsPath at all. Confirmed
        # 2026-09-29: this is exactly the "no Servants in Formation, only CEs"
        # bug - it doesn't need the server running to reproduce, this key
        # is just plain unparsable Linux-side no matter when it's read. Also
        # affects scooby.exe's own writes here (C#'s Path.GetRelativePath()
        # emits backslashes too when run under Wine), so this isn't
        # something specific to this tool's output.
        relative_cards_path = os.path.relpath(self.cards_path, install_root() / "App").replace(os.sep, "/")
        selected_cards = [f"{relative_cards_path}/{entry['card']['file_name']}" for entry in self.selected.values()]
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


class DrawRatesTab(ttk.Frame):
    """Server/artemis's own local summon-weight lottery
    (Server/artemis/titles/fgo/summon_weights.py) - a flat weighted pool
    across every eligible Servant/CE base print (no story-only entries, no
    holo/alt-art variants - those were never summonable at all, not
    something this tab is hiding). Not a retail probability table, and not
    scooby's own UI at all - scooby has no Draw Rates view of its own; this
    reads/writes the same server config file directly. Requires restarting
    the local server (Server tab's Restart Server button) to take effect."""

    PAGE_SIZE = 40
    THUMB_SIZE = (56, 86)

    def __init__(self, parent):
        super().__init__(parent, padding=12)
        self.thumb_cache = {}
        self.cards = []
        self.weights = {}
        self.weight_vars = {}
        self.filtered = []
        self.page = 0
        self.cards_path = install_root() / "DEVICE" / "print" / "FGO11_AllServants"

        if not HAVE_PIL:
            ttk.Label(self, text="Pillow (python3-Pillow) is required for card artwork here - install it and restart.",
                      foreground="red", wraplength=500).pack(padx=8, pady=8)
            return

        ttk.Label(self, text="Local simulation weights, not a retail probability table. A weight of 0 removes "
                              "a card from the pool entirely; equal nonzero weights split evenly. Restart the "
                              "local server (Server tab's Restart Server button) after saving for changes to "
                              "take effect.",
                  foreground="gray", wraplength=780).pack(anchor="w", pady=(0, 8))

        toolbar = ttk.Frame(self)
        toolbar.pack(fill="x")
        ttk.Label(toolbar, text="Show").pack(side="left")
        self.show_var = tk.StringVar(value="All Cards")
        ttk.Combobox(toolbar, textvariable=self.show_var, values=[n for n, _ in CARD_TYPE_CHOICES],
                     state="readonly", width=14).pack(side="left", padx=(4, 12))
        self.show_var.trace_add("write", lambda *_: self._apply_filter())
        ttk.Label(toolbar, text="Sort").pack(side="left")
        self.sort_var = tk.StringVar(value="Name")
        ttk.Combobox(toolbar, textvariable=self.sort_var, values=["Name", "Rarity", "TC ID"],
                     state="readonly", width=10).pack(side="left", padx=(4, 12))
        self.sort_var.trace_add("write", lambda *_: self._apply_filter())
        ttk.Label(toolbar, text="Search:").pack(side="left", padx=(8, 0))
        self.search_var = tk.StringVar()
        self.search_var.trace_add("write", lambda *_: self._apply_filter())
        ttk.Entry(toolbar, textvariable=self.search_var, width=24).pack(side="left", padx=(4, 0))

        bulk = ttk.Frame(self)
        bulk.pack(fill="x", pady=(6, 0))
        ttk.Label(bulk, text="Set all shown to:").pack(side="left")
        self.bulk_value_var = tk.StringVar(value="1")
        ttk.Entry(bulk, textvariable=self.bulk_value_var, width=8).pack(side="left", padx=(4, 6))
        ttk.Button(bulk, text="Apply", command=self._bulk_set_shown).pack(side="left")
        ttk.Button(bulk, text="Disable shown (0)", command=lambda: self._bulk_set_shown(0)).pack(side="left", padx=(8, 0))
        ttk.Button(bulk, text="Reset shown to 1", command=lambda: self._bulk_set_shown(1)).pack(side="left", padx=(4, 0))

        self.summary_var = tk.StringVar(value="")
        ttk.Label(self, textvariable=self.summary_var, foreground="gray").pack(anchor="w", pady=(8, 4))

        nav = ttk.Frame(self)
        nav.pack(fill="x")
        self.page_label_var = tk.StringVar(value="")
        ttk.Label(nav, textvariable=self.page_label_var).pack(side="left")
        ttk.Button(nav, text="< Prev", command=self._prev_page).pack(side="left", padx=(12, 0))
        ttk.Button(nav, text="Next >", command=self._next_page).pack(side="left", padx=(4, 0))

        body = ttk.Frame(self)
        body.pack(fill="both", expand=True, pady=(8, 0))
        self.list_canvas = tk.Canvas(body, highlightthickness=0)
        list_scroll = ttk.Scrollbar(body, orient="vertical", command=self.list_canvas.yview)
        self.list_canvas.configure(yscrollcommand=list_scroll.set)
        list_scroll.pack(side="right", fill="y")
        self.list_canvas.pack(side="left", fill="both", expand=True)
        self.list_frame = ttk.Frame(self.list_canvas)
        self.list_canvas.create_window((0, 0), window=self.list_frame, anchor="nw")
        self.list_frame.bind("<Configure>", lambda e: self.list_canvas.configure(scrollregion=self.list_canvas.bbox("all")))

        bottom = ttk.Frame(self)
        bottom.pack(fill="x", pady=(8, 0))
        ttk.Button(bottom, text="Save Weights", command=self.save).pack(side="left")
        self.status_var = tk.StringVar(value="")
        ttk.Label(bottom, textvariable=self.status_var, foreground="gray").pack(side="left", padx=(12, 0))

        # Presets - a named rate table you can switch between, share, or keep
        # as a starting point (e.g. "everyone equal" vs "only my favorites")
        # - separate from the single live weights file Save Weights writes.
        # Matches scooby's own SummonSettingsWindow Presets row exactly (same
        # file format, same folder), so a preset saved by either tool loads
        # in the other.
        presets_row = ttk.Frame(self)
        presets_row.pack(fill="x", pady=(6, 0))
        ttk.Label(presets_row, text="Presets:").pack(side="left")
        self.preset_var = tk.StringVar()
        self.preset_combo = ttk.Combobox(presets_row, textvariable=self.preset_var, state="readonly", width=24)
        self.preset_combo.pack(side="left", padx=(4, 8))
        ttk.Button(presets_row, text="Save as", command=self._preset_save).pack(side="left")
        ttk.Button(presets_row, text="Load", command=self._preset_load).pack(side="left", padx=(4, 0))
        ttk.Button(presets_row, text="Delete", command=self._preset_delete).pack(side="left", padx=(4, 0))
        ttk.Button(presets_row, text="Export", command=self._preset_export).pack(side="left", padx=(12, 0))
        ttk.Button(presets_row, text="Import", command=self._preset_import).pack(side="left", padx=(4, 0))
        preset_folder_link = ttk.Label(presets_row, text="Open folder", foreground="#3d8fd6", cursor="hand2")
        preset_folder_link.pack(side="left", padx=(12, 0))
        preset_folder_link.bind("<Button-1>", lambda e: self._preset_open_folder())

        self.reload()

    def reload(self):
        self.cards = load_summon_candidates()
        eligible_ids = {c["tc_id"] for c in self.cards}
        self.weights = load_summon_weights(eligible_ids)
        self._refresh_presets()
        self._apply_filter()

    def _apply_filter(self):
        if not hasattr(self, "summary_var"):
            return  # HAVE_PIL was False - no widgets were built at all
        show_type = {n: v for n, v in CARD_TYPE_CHOICES}.get(self.show_var.get(), 0)
        query = self.search_var.get().strip().lower()

        def matches(card):
            if show_type and card["card_type_id"] != show_type:
                return False
            if not query:
                return True
            name = DeckTab._display_name(card).lower()
            internal_id = (TRANSLATIONS.internal_id(card) or "").lower()
            return query in name or query in internal_id or query in str(card["tc_id"])

        filtered = [c for c in self.cards if matches(c)]
        sort_mode = self.sort_var.get()
        if sort_mode == "Name":
            filtered.sort(key=lambda c: DeckTab._display_name(c).lower())
        elif sort_mode == "Rarity":
            filtered.sort(key=lambda c: (-c.get("rarity", 0), DeckTab._display_name(c).lower()))
        elif sort_mode == "TC ID":
            filtered.sort(key=lambda c: c["tc_id"])
        self.filtered = filtered
        self.page = 0
        self._render_page()

        servant_total = sum(1 for c in self.cards if c["card_type_id"] == 1)
        ce_total = sum(1 for c in self.cards if c["card_type_id"] == 2)
        nonzero = sum(1 for w in self.weights.values() if w > 0)
        self.summary_var.set(f"Servants {servant_total:,} / Craft Essences {ce_total:,} eligible - "
                              f"{len(filtered):,} shown - {nonzero:,} currently in the pool (nonzero weight)")

    def _prev_page(self):
        if self.page > 0:
            self.page -= 1
            self._render_page()

    def _next_page(self):
        if (self.page + 1) * self.PAGE_SIZE < len(self.filtered):
            self.page += 1
            self._render_page()

    def _thumbnail(self, card):
        file_name = card["file_name"]
        if not file_name:
            return None
        if file_name in self.thumb_cache:
            return self.thumb_cache[file_name]
        try:
            image = Image.open(self.cards_path / file_name)
            image.thumbnail(self.THUMB_SIZE)
            photo = ImageTk.PhotoImage(image)
        except (OSError, ValueError):
            photo = None
        self.thumb_cache[file_name] = photo
        return photo

    def _render_page(self):
        for child in self.list_frame.winfo_children():
            child.destroy()
        self.weight_vars = {}
        start = self.page * self.PAGE_SIZE
        for card in self.filtered[start:start + self.PAGE_SIZE]:
            tc_id = card["tc_id"]
            row = ttk.Frame(self.list_frame, padding=4)
            row.pack(fill="x", pady=1)
            photo = self._thumbnail(card)
            if photo is not None:
                thumb = tk.Label(row, image=photo)
                thumb.image = photo
            else:
                thumb = tk.Label(row, text="(no image)", width=8, height=4)
            thumb.grid(row=0, column=0, rowspan=2, padx=(0, 10))
            ttk.Label(row, text=DeckTab._display_name(card), font=("", 10, "bold")).grid(row=0, column=1, sticky="w")
            type_label = "Servant" if card["card_type_id"] == 1 else "Craft Essence"
            rarity = card.get("rarity", 0)
            stars = ("*" * rarity) if rarity else "?"
            ttk.Label(row, text=f"{type_label} - {stars} - TC {tc_id}", foreground="gray").grid(
                row=1, column=1, sticky="w")
            row.grid_columnconfigure(1, weight=1)
            ttk.Label(row, text="Weight:").grid(row=0, column=2, rowspan=2, sticky="e", padx=(12, 4))
            var = tk.StringVar(value=str(self.weights.get(tc_id, 0)))
            self.weight_vars[tc_id] = var
            spin = ttk.Spinbox(row, from_=0, to=MAX_SUMMON_WEIGHT, textvariable=var, width=10)
            spin.grid(row=0, column=3, rowspan=2, sticky="e")
            spin.bind("<FocusOut>", lambda e, tc=tc_id, v=var: self._commit_weight(tc, v))
            spin.bind("<Return>", lambda e, tc=tc_id, v=var: self._commit_weight(tc, v))
        total_pages = max(1, (len(self.filtered) + self.PAGE_SIZE - 1) // self.PAGE_SIZE)
        self.page_label_var.set(f"Page {self.page + 1}/{total_pages}")

    def _commit_weight(self, tc_id, var):
        try:
            value = max(0, min(MAX_SUMMON_WEIGHT, int(var.get())))
        except ValueError:
            value = self.weights.get(tc_id, 0)
        var.set(str(value))
        self.weights[tc_id] = value

    def _bulk_set_shown(self, value=None):
        if value is None:
            try:
                value = max(0, min(MAX_SUMMON_WEIGHT, int(self.bulk_value_var.get())))
            except ValueError:
                self.status_var.set("Enter a whole number from 0 to 1,000,000 first.")
                return
        for card in self.filtered:
            self.weights[card["tc_id"]] = value
        self._render_page()
        self.status_var.set(f"Set {len(self.filtered):,} shown card(s) to weight {value}. Remember to Save.")

    def save(self):
        for tc_id, var in self.weight_vars.items():
            self._commit_weight(tc_id, var)
        try:
            save_summon_weights(self.weights)
        except ValueError as exc:
            self.status_var.set(str(exc))
            return
        self.status_var.set("Saved. Restart the local server (Server tab's Restart Server button) "
                             "for changes to take effect.")

    # --- presets (Server/artemis/config/summon-presets/<name>.json) --------
    # Same {"version": 1, "weights": {...}} shape as the live weights file
    # itself (scooby's own BuildWeightsJson() - a preset IS just a saved
    # copy of that file), so a preset either tool saves loads in the other.

    def _refresh_presets(self, select=None):
        folder = summon_presets_folder()
        names = sorted(p.stem for p in folder.glob("*.json")) if folder.is_dir() else []
        self.preset_combo["values"] = names
        if select is not None and select in names:
            self.preset_var.set(select)
        elif self.preset_var.get() not in names:
            self.preset_var.set("")

    @staticmethod
    def _looks_like_preset(data):
        return isinstance(data, dict) and data.get("version") == 1 and isinstance(data.get("weights"), dict)

    def _preset_save(self):
        for tc_id, var in self.weight_vars.items():
            self._commit_weight(tc_id, var)
        name = simpledialog.askstring("Save preset", "Name for this rate table:",
                                       initialvalue=self.preset_var.get(), parent=self.winfo_toplevel())
        if not name:
            return
        folder = summon_presets_folder()
        folder.mkdir(parents=True, exist_ok=True)
        target = folder / f"{name}.json"
        if target.exists() and not messagebox.askyesno("Save preset", f'Replace the preset "{name}"?'):
            return
        payload = {"version": 1, "weights": {str(tc_id): int(w) for tc_id, w in sorted(self.weights.items())}}
        try:
            target.write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
        except OSError as exc:
            self.status_var.set(f"The preset could not be saved: {exc}")
            return
        self._refresh_presets(select=name)
        self.status_var.set(f"Preset saved: {name}. The live rates are unchanged until you click "
                             "Save Weights. Export sends a copy to share.")

    def _apply_preset_file(self, path, name):
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            self.status_var.set("That file is not a draw-rate preset.")
            return
        if not self._looks_like_preset(data):
            self.status_var.set("That file is not a draw-rate preset.")
            return
        eligible_ids = {c["tc_id"] for c in self.cards}
        skipped = 0
        for key, value in data["weights"].items():
            try:
                tc_id = int(key)
                weight = max(0, min(MAX_SUMMON_WEIGHT, int(value)))
            except (TypeError, ValueError):
                skipped += 1
                continue
            if tc_id not in eligible_ids:
                skipped += 1
                continue
            self.weights[tc_id] = weight
        self._render_page()
        suffix = (f" ({skipped} card(s) in the file are not in your game and were left out)"
                  if skipped else "")
        self.status_var.set(f"Preset loaded: {name}{suffix}. Click Save Weights to make the server use it.")

    def _preset_load(self):
        name = self.preset_var.get()
        if not name:
            return
        self._apply_preset_file(summon_presets_folder() / f"{name}.json", name)

    def _preset_delete(self):
        name = self.preset_var.get()
        if not name:
            return
        if not messagebox.askyesno("Delete preset", f'Delete the preset "{name}"?'):
            return
        (summon_presets_folder() / f"{name}.json").unlink(missing_ok=True)
        self._refresh_presets()
        self.status_var.set(f"Preset deleted: {name}")

    def _preset_export(self):
        name = self.preset_var.get()
        if not name:
            self.status_var.set("Select a preset to export, or Save as first.")
            return
        source = summon_presets_folder() / f"{name}.json"
        desktop = Path.home() / "Desktop"
        dest = filedialog.asksaveasfilename(
            title="Export preset", initialfile=f"{name}.json", defaultextension=".json",
            initialdir=str(desktop if desktop.is_dir() else Path.home()), filetypes=[("Draw-rate preset", "*.json")])
        if not dest:
            return
        try:
            shutil.copyfile(source, dest)
        except OSError as exc:
            self.status_var.set(f"The preset could not be exported: {exc}")
            return
        self.status_var.set(f"Exported: {Path(dest).name} - send it to anyone with the launcher; "
                             "they add it with Import.")

    def _preset_import(self):
        source = filedialog.askopenfilename(title="Import preset", filetypes=[("Draw-rate preset", "*.json")])
        if not source:
            return
        try:
            data = json.loads(Path(source).read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            messagebox.showerror("Import", "That file is not a draw-rate preset. Pick a .json file that "
                                            "was exported from the Presets row.")
            return
        if not self._looks_like_preset(data):
            messagebox.showerror("Import", "That file is not a draw-rate preset. Pick a .json file that "
                                            "was exported from the Presets row.")
            return
        name = Path(source).stem
        folder = summon_presets_folder()
        folder.mkdir(parents=True, exist_ok=True)
        target = folder / f"{name}.json"
        try:
            shutil.copyfile(source, target)
        except OSError as exc:
            self.status_var.set(f"The preset could not be imported: {exc}")
            return
        self._refresh_presets(select=name)
        self._apply_preset_file(target, name)

    def _preset_open_folder(self):
        folder = summon_presets_folder()
        folder.mkdir(parents=True, exist_ok=True)
        try:
            subprocess.Popen(["xdg-open", str(folder)])
        except OSError:
            messagebox.showinfo("Open folder", str(folder))


class BannersTab(ttk.Frame):
    """scooby calls this "Banners", but it's actually a Limited-Time-Event
    (LTE) story/menu VISIBILITY filter, not gacha pool/rate editing (that's
    the Draw Rates tab above - a separate, unrelated system). Checking one
    or more events here hides every OTHER event's story nodes/banners from
    the in-game Terminal; checking none shows everything (no filter).

    Needs a one-time source patch to two ARTEMiS Python files before the
    checkboxes do anything at all - the base install has no
    enabled_singularity_ids concept until it's patched in. That patch
    changes server source code (with a .bak alongside each file it touches,
    plus a py_compile check that auto-restores on failure) - deliberately
    left as an explicit button rather than applied automatically."""

    def __init__(self, parent):
        super().__init__(parent, padding=16)
        self.vars = {}

        header = ttk.Frame(self)
        header.pack(fill="x", pady=(0, 10))
        self.patch_status_var = tk.StringVar(value=self._describe_status(event_toggle_status()))
        ttk.Label(header, textvariable=self.patch_status_var, foreground="gray", wraplength=760).pack(anchor="w")
        ttk.Button(header, text="Apply Event Toggle Patch", command=self._apply_patch).pack(anchor="w", pady=(6, 0))

        ttk.Label(self, text="Checking one or more events below hides every OTHER event's story nodes/menus "
                              "in-game. Checking none shows everything (no filter). Restart the local server "
                              "(Server tab's Restart Server button) after Save for this to take effect.",
                  foreground="gray", wraplength=760).pack(anchor="w", pady=(0, 10))

        actions = ttk.Frame(self)
        actions.pack(fill="x", pady=(0, 6))
        ttk.Button(actions, text="Save", command=self.save).pack(side="left")
        ttk.Button(actions, text="Clear All (show everything)", command=self._clear_all).pack(side="left", padx=(8, 0))
        self.status_var = tk.StringVar(value="")
        ttk.Label(actions, textvariable=self.status_var, foreground="gray").pack(side="left", padx=(12, 0))

        list_container = ttk.Frame(self)
        list_container.pack(fill="both", expand=True)
        canvas = tk.Canvas(list_container, highlightthickness=0)
        scroll = ttk.Scrollbar(list_container, orient="vertical", command=canvas.yview)
        canvas.configure(yscrollcommand=scroll.set)
        scroll.pack(side="right", fill="y")
        canvas.pack(side="left", fill="both", expand=True)
        inner = ttk.Frame(canvas)
        canvas.create_window((0, 0), window=inner, anchor="nw")
        inner.bind("<Configure>", lambda e: canvas.configure(scrollregion=canvas.bbox("all")))

        enabled_ids = load_enabled_singularity_ids()
        for lte_id, label in EVENT_TOGGLE_IDS:
            var = tk.BooleanVar(value=lte_id in enabled_ids)
            self.vars[lte_id] = var
            ttk.Checkbutton(inner, text=f"LTE{lte_id} - {label}", variable=var).pack(anchor="w", pady=2)

    @staticmethod
    def _describe_status(status):
        if all(v is True for v in status.values()):
            return "Event Toggle Patch: applied."
        if any(v is None for v in status.values()):
            missing = ", ".join(k for k, v in status.items() if v is None)
            return f"Event Toggle Patch: not applied - target file(s) not found ({missing})."
        return "Event Toggle Patch: not applied yet - the checkboxes below do nothing until this runs."

    def _apply_patch(self):
        try:
            messages = apply_event_toggle_patch()
        except Exception as exc:
            self.patch_status_var.set(f"Could not apply the patch: {exc}")
            return
        self.patch_status_var.set("\n".join(messages) + "\n" + self._describe_status(event_toggle_status()))

    def _clear_all(self):
        for var in self.vars.values():
            var.set(False)

    def save(self):
        ids = {lte_id for lte_id, var in self.vars.items() if var.get()}
        try:
            save_enabled_singularity_ids(ids)
        except Exception as exc:
            self.status_var.set(f"Could not save: {exc}")
            return
        restart_hint = "Restart the local server (Server tab's Restart Server button) for this to take effect."
        if ids:
            self.status_var.set(f"Saved - {len(ids)} event(s) allowed, everything else hidden. {restart_hint}")
        else:
            self.status_var.set(f"Saved - no filter (everything shows). {restart_hint}")


class App(tk.Tk):
    def __init__(self):
        super().__init__()
        root = install_root_or_none()
        self.title(f"FGO Arcade settings - {root or '(no install configured)'}")
        self.geometry("980x760")
        self.minsize(760, 560)

        self.notebook = ttk.Notebook(self)

        self.setup_tab = SetupTab(self.notebook, on_saved=self._on_setup_saved)
        self.notebook.add(self.setup_tab, text="Setup")

        self.display_tab = self.controls_tab = self.server_tab = None
        self.account_tab = self.deck_tab = self.draw_rates_tab = self.banners_tab = None
        if root is not None:
            self._build_install_tabs()
        else:
            placeholder = ttk.Frame(self.notebook, padding=24)
            ttk.Label(placeholder, text="No FGO Arcade install configured yet.\n"
                                         "Fill in the Setup tab, click Save, then restart this app.",
                      justify="center").pack(expand=True)
            self.notebook.add(placeholder, text="(configure Setup first)")

        # Packed (and its side="bottom" set) before the notebook, so it
        # always keeps its space at the bottom of the window regardless of
        # how tall the notebook's own content is - previously the notebook
        # was packed first with expand=True and claimed the window outright,
        # leaving this row clipped off-screen below the window's bottom edge
        # on the default (or a manually shrunk) window size.
        button_row = ttk.Frame(self, padding=(8, 6, 8, 8))
        button_row.pack(side="bottom", fill="x")
        ttk.Button(button_row, text="Save", command=self.on_save).pack(side="left")
        ttk.Button(button_row, text="Save && Play", command=self.on_play).pack(side="left", padx=(8, 0))
        self.status_var = tk.StringVar(value="")
        ttk.Label(button_row, textvariable=self.status_var, foreground="gray").pack(side="left", padx=(16, 0))

        self.notebook.pack(fill="both", expand=True, padx=8, pady=(8, 0))

    def _build_install_tabs(self):
        self.display_tab = DisplayTab(self.notebook)
        self.controls_tab = ControlsTab(self.notebook)
        self.server_tab = ServerTab(self.notebook)
        self.account_tab = AccountTab(self.notebook)
        self.deck_tab = DeckTab(self.notebook)
        self.draw_rates_tab = DrawRatesTab(self.notebook)
        self.banners_tab = BannersTab(self.notebook)
        self.notebook.add(self.display_tab, text="Game Settings")
        self.notebook.add(self.controls_tab, text="Controls")
        self.notebook.add(self.server_tab, text="Server")
        self.notebook.add(self.account_tab, text="Account")
        self.notebook.add(self.deck_tab, text="Deck")
        self.notebook.add(self.draw_rates_tab, text="Draw Rates")
        self.notebook.add(self.banners_tab, text="Banners")

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
        try:
            subprocess.Popen([str(linux_dir / "fgo-launcher.sh")])
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
