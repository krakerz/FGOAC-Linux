#!/usr/bin/env bash
# Linux port of Apply-EN-Patch.ps1.
#
# Runs directly against the Linux filesystem path to the game folder (e.g.
# inside a Wine prefix's drive_c) - no wine invocation needed, since this
# only copies/checksums files and edits JSON. Dropped: the WinForms folder
# picker (replaced with zenity, falling back to a plain prompt),
# Win32_LogicalDisk drive scanning (there's no Windows-style multi-drive
# concept to scan on Linux), and UAC elevation (file ownership under a Wine
# prefix is normally already yours; if it isn't, this tells you to fix
# permissions instead of re-launching itself as root).
#
# Usage: apply-en-patch.sh [--install-root PATH] [--package-root PATH] [--rollback] [--force] [--non-interactive]
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
fgo_require_cmd "$FGO_PYTHON"

install_root="" package_root="${FGO_PACKAGE_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}" rollback=0 force=0 non_interactive=0
while [ $# -gt 0 ]; do
    case "$1" in
        --install-root) install_root=$2; shift 2 ;;
        --package-root) package_root=$2; shift 2 ;;
        --rollback) rollback=1; shift ;;
        --force) force=1; shift ;;
        --non-interactive) non_interactive=1; shift ;;
        *) fgo_die "Unknown option: $1" 1 ;;
    esac
done

is_fgo_install_root() {
    [ -f "$1/App/ago.exe" ] && [ -f "$1/App/fgo-launcher.json" ] && [ -d "$1/Server" ]
}

if [ -z "$install_root" ]; then
    for candidate in "${FGO_INSTALL_ROOT:-}" "$package_root" "$(dirname "$package_root")"; do
        [ -n "$candidate" ] || continue
        if is_fgo_install_root "$candidate"; then install_root=$candidate; break; fi
    done
fi
if [ -z "$install_root" ] && [ "$non_interactive" -eq 0 ] && command -v zenity >/dev/null 2>&1; then
    install_root=$(zenity --file-selection --directory \
        --title="Select your FGO Arcade folder - the one that holds App and Server" 2>/dev/null) || true
fi
if [ -z "$install_root" ] && [ "$non_interactive" -eq 0 ]; then
    read -r -p "Path to your FGO Arcade folder (holds App/ and Server/): " install_root
fi
[ -z "$install_root" ] && fgo_die "No FGO Arcade folder was chosen, so nothing was changed." 8
is_fgo_install_root "$install_root" || fgo_die "That folder is not an FGO Arcade install: $install_root. Choose the folder that holds App/ago.exe, App/fgo-launcher.json and the Server folder." 2
install_root=$(cd "$install_root" && pwd)
package_root=$(cd "$package_root" && pwd)

if [ ! -w "$install_root" ] || [ ! -w "$install_root/App" ]; then
    fgo_die "Cannot write to $install_root. Fix ownership/permissions of this folder (it's normally owned by you inside a Wine prefix) and try again." 1
fi

running=()
for name in ago.exe amdaemon.exe inject.exe FGOLocalPlatform.exe "FGOAC scooby.exe"; do
    while read -r pid cmd; do
        case "$cmd" in "$install_root"*"$name"*) running+=("$name (pid $pid)") ;; esac
    done < <(pgrep -af "$name" 2>/dev/null)
done
if [ "${#running[@]}" -gt 0 ]; then
    fgo_die "Close the game and the launcher in $install_root first, then run the patch again. Still running: ${running[*]}" 4
fi

marker_path="$install_root/App/zh/en-patch.json"

if [ "$rollback" -eq 1 ]; then
    output=$("$FGO_PYTHON" "$SCRIPT_DIR/tools/apply_patch_files.py" rollback "$install_root" "$marker_path") || exit $?
    fgo_log "$("$FGO_PYTHON" -c 'import json,sys; print(json.loads(sys.argv[1])["message"])' "$output")"
    fgo_log "The launcher settings were left as they are; turn English Text off in the launcher if you want the Chinese set back."
    exit 0
fi

[ -f "$install_root/App/FGO_Runtime.dll" ] || fgo_die "This game folder has not had Cloud23333's V1.01 update yet: App/FGO_Runtime.dll is missing, and the English patch needs it." 9

manifest_path="$package_root/manifest.json"
# manifest.json is the normal packaged-release case; apply_patch_files.py
# also accepts package_root pointing straight at (or containing) a plain
# payload/ folder with no manifest at all (e.g. a source checkout), building
# the file list from that instead - so no hard requirement here, just pass
# the path through and let it decide.

fgo_log "Applying the English patch to $install_root..."
if ! output=$("$FGO_PYTHON" "$SCRIPT_DIR/tools/apply_patch_files.py" apply "$install_root" "$package_root" "$manifest_path" "$marker_path" "$force"); then
    exit $?
fi
"$FGO_PYTHON" -c 'import json,sys; print(json.loads(sys.argv[1])["message"])' "$output"

# chineseEnabled is the switch that makes the game read App/zh, which now
# holds the English set.
"$FGO_PYTHON" -c '
import json, sys
path = sys.argv[1]
config = json.loads(open(path, encoding="utf-8").read())
if config.get("chineseEnabled") is not True:
    config["chineseEnabled"] = True
    open(path, "w", encoding="utf-8").write(json.dumps(config, ensure_ascii=False, indent=2))
    print("Turned the English text on in the launcher settings.")
' "$install_root/App/fgo-launcher.json" || fgo_warn "Could not set chineseEnabled in App/fgo-launcher.json. Open the launcher and turn English Text on yourself."

fgo_log "Done."
