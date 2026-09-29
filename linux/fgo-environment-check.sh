#!/usr/bin/env bash
# Linux port of payload/App/FGO_EnvironmentCheck.ps1.
#
# Windows/PowerShell-version and Windows-Audio-service checks are dropped
# (meaningless on Linux); DLL loadability is approximated by file-existence
# instead of an actual LoadLibrary call, since that would require running
# inside Wine. Exits 0 if every check passes, 1 if any needs action - each
# line is still printed either way, same as the original's report style.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
fgo_require_install_root

failed=0
check() { # name passed(0/1) detail
    if [ "$2" -eq 0 ]; then
        printf '[PASS] %s: %s\n' "$1" "$3"
    else
        printf '[ACTION NEEDED] %s: %s\n' "$1" "$3"
        failed=1
    fi
}

game_root="$FGO_INSTALL_ROOT/App"

if command -v "${FGO_WINE:-wine}" >/dev/null 2>&1; then
    check "Wine" 0 "Found $("${FGO_WINE:-wine}" --version 2>/dev/null)."
else
    check "Wine" 1 "'${FGO_WINE:-wine}' was not found on PATH. Install Wine (or set FGO_WINE to your Proton/wine binary)."
fi

if [ -z "${WINEPREFIX:-}" ]; then
    check "WINEPREFIX" 1 "WINEPREFIX is not set; wine would use its default prefix (~/.wine) instead of this game's."
else
    check "WINEPREFIX" 0 "$WINEPREFIX"
fi

vc_runtimes=(
    "Visual C++ 2010 x64|msvcr100.dll msvcp100.dll"
    "Visual C++ 2012 x64|msvcr110.dll msvcp110.dll"
    "Visual C++ v14 x64|vcruntime140.dll vcruntime140_1.dll msvcp140.dll"
)
for entry in "${vc_runtimes[@]}"; do
    label=${entry%%|*}; files=${entry#*|}
    vc_missing=()
    for f in $files; do
        if [ -f "$game_root/$f" ] || [ -f "$game_root/am/$f" ] || \
           { [ -n "${WINEPREFIX:-}" ] && [ -f "$WINEPREFIX/drive_c/windows/system32/$f" ]; }; then
            :
        else
            vc_missing+=("$f")
        fi
    done
    if [ "${#vc_missing[@]}" -eq 0 ]; then
        check "$label" 0 "Found: $files."
    else
        check "$label" 1 "Missing: ${vc_missing[*]}. Reapply the full package, or run: winetricks vcrun2010 vcrun2012 vcrun2019"
    fi
done

if command -v pactl >/dev/null 2>&1; then
    sink_count=$(pactl list short sinks 2>/dev/null | wc -l)
    if [ "$sink_count" -gt 0 ]; then
        check "Audio Output Device" 0 "$sink_count sink(s) found via pactl."
    else
        check "Audio Output Device" 1 "pactl reports no sinks. Connect or enable an output device."
    fi
elif command -v aplay >/dev/null 2>&1 && aplay -l >/dev/null 2>&1; then
    check "Audio Output Device" 0 "aplay -l reports at least one device."
else
    check "Audio Output Device" 1 "Neither pactl nor aplay could confirm an audio output device."
fi

required=(App/ago.exe App/am/amdaemon.exe App/fgohook.dll App/FGO_Runtime.dll App/inject.exe \
    "App/Tools/Locale_Remulator/LRHookx64.dll" App/config.json App/segatools.ini AMFS/ICF1 AMFS/ICF2 \
    Server/mariadb-10.11.16-winx64/bin/mariadbd.exe)
files_missing=()
for rel in "${required[@]}"; do [ -f "$FGO_INSTALL_ROOT/$rel" ] || files_missing+=("$rel"); done
if [ "${#files_missing[@]}" -eq 0 ]; then
    check "Game and Server Files" 0 "The core program files are present; this does not verify every ROM resource."
else
    check "Game and Server Files" 1 "Missing: ${files_missing[*]}."
fi

if py_out=$("$FGO_PYTHON" -I -c "import sys,yaml,sqlalchemy,aiomysql,uvicorn,starlette,Crypto; print(sys.version.split()[0])" 2>&1); then
    check "Python and Server Libraries ($FGO_PYTHON)" 0 "Python $py_out and the main server libraries load."
else
    check "Python and Server Libraries ($FGO_PYTHON)" 1 "$py_out -- install with: $FGO_PYTHON -m pip install pyyaml sqlalchemy aiomysql uvicorn starlette pycryptodome (or set FGO_PYTHON to a venv that already has them)"
fi

for rel in App AMFS GameData DEVICE Server/state Server/data/mariadb logs; do
    path="$FGO_INSTALL_ROOT/$rel"
    mkdir -p "$path" 2>/dev/null
    probe="$path/.fgo-env-$$-$RANDOM"
    if ( : > "$probe" ) 2>/dev/null; then
        rm -f "$probe"
        check "Folder permissions: $rel" 0 "Temporary files can be created and deleted."
    else
        check "Folder permissions: $rel" 1 "Cannot write. Check ownership/permissions of the Wine prefix and that the drive is not full."
    fi
done

check "Network Mode" 0 "TCP reachability is checked directly by start-fgo-local-server.sh and fgo-launcher.sh; this check does not start the server."

exit $failed
