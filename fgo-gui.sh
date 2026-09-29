#!/usr/bin/env bash
# Standalone settings + launcher GUI (Setup/Display/Controls/Server/Account/
# Deck + Play), a Linux-native alternative to scooby.exe. See
# linux/tools/fgo_gui.py for what it actually does and why. Lives at the
# project root (not linux/) so it's the obvious first thing to run.
#
# Deliberately run with plain system python3, not $FGO_PYTHON (the ARTEMiS
# server's venv) - needs tkinter (stdlib), Pillow for card artwork, and
# optionally evdev for live gamepad-button capture; none of the server venv's
# business.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LINUX_DIR="$SCRIPT_DIR/linux"
. "$LINUX_DIR/lib/common.sh"

command -v python3 >/dev/null 2>&1 || fgo_die "python3 is required." 1
python3 -c "import tkinter" 2>/dev/null || fgo_die "python3's tkinter module is required (e.g. 'pacman -S tk' or 'apt install python3-tk')." 1

export FGO_INSTALL_ROOT FGO_PYTHON FGO_WINE WINEPREFIX FGO_PACKAGE_ROOT FGO_SCOOBY_SRC
exec python3 "$LINUX_DIR/tools/fgo_gui.py"
