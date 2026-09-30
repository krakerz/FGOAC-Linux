#!/usr/bin/env bash
# One-time (idempotent - safe to re-run) setup for a fresh copy of this
# project: creates fgo.env from the template if missing, creates a venv at
# ./venv with everything the ARTEMiS server needs, and points FGO_PYTHON at
# it in fgo.env. Re-running just tops up the venv's packages.
#
# Usage: setup.sh [--install-root PATH] [--wineprefix PATH] [--wine BINARY]
# Any flag you pass gets written into fgo.env; flags you don't pass leave
# the existing value (or the template's placeholder) alone.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/venv"
ENV_FILE="$SCRIPT_DIR/fgo.env"
ENV_EXAMPLE="$SCRIPT_DIR/fgo.env.example"

install_root="" wineprefix="" wine_bin=""
while [ $# -gt 0 ]; do
    case "$1" in
        --install-root) install_root=$2; shift 2 ;;
        --wineprefix) wineprefix=$2; shift 2 ;;
        --wine) wine_bin=$2; shift 2 ;;
        *) echo "Unknown option: $1" >&2; exit 1 ;;
    esac
done

command -v python3 >/dev/null 2>&1 || { echo "python3 is required." >&2; exit 1; }

if [ ! -f "$ENV_FILE" ]; then
    cp "$ENV_EXAMPLE" "$ENV_FILE"
    echo "Created $ENV_FILE from the template."
fi

set_env_value() { # key value
    local key=$1 value=$2
    if grep -q "^${key}=" "$ENV_FILE"; then
        sed -i "s|^${key}=.*|${key}=\"${value}\"|" "$ENV_FILE"
    elif grep -q "^#${key}=" "$ENV_FILE"; then
        sed -i "s|^#${key}=.*|${key}=\"${value}\"|" "$ENV_FILE"
    else
        printf '%s="%s"\n' "$key" "$value" >> "$ENV_FILE"
    fi
}

[ -n "$install_root" ] && set_env_value FGO_INSTALL_ROOT "$install_root"
[ -n "$wineprefix" ] && set_env_value WINEPREFIX "$wineprefix"
[ -n "$wine_bin" ] && set_env_value FGO_WINE "$wine_bin"

if [ ! -x "$VENV_DIR/bin/python" ]; then
    echo "Creating venv at $VENV_DIR ..."
    # --copies (not symlinks): keeps the venv's python a real, independent
    # binary rather than a chain of symlinks back to the system interpreter -
    # matters if you ever need to grant it a capability (setcap) without
    # affecting the system python too.
    python3 -m venv --copies "$VENV_DIR"
fi

# Read fgo.env now (after any --install-root etc. above) just to find
# Server/artemis/requirements.txt; doesn't affect this shell beyond that.
current_install_root=""
if [ -f "$ENV_FILE" ]; then
    current_install_root=$(sed -n 's/^FGO_INSTALL_ROOT="\(.*\)"$/\1/p' "$ENV_FILE" | tail -n1)
fi

requirements=""
if [ -n "$current_install_root" ] && [ -f "$current_install_root/Server/artemis/requirements.txt" ]; then
    requirements="$current_install_root/Server/artemis/requirements.txt"
fi

echo "Installing Python dependencies into $VENV_DIR ..."
# One plain line per step (no --quiet, no redrawn progress bar), so a long
# first install visibly progresses - in a terminal and in the GUI's Output box.
pip_install() { "$VENV_DIR/bin/pip" install --disable-pip-version-check --progress-bar off "$@"; }
pip_install --upgrade pip
if [ -n "$requirements" ]; then
    # pylibmc needs libmemcached's C headers, which most systems don't have
    # installed, and is only used when core.yaml's enable_memcached is true
    # (try-imported, degrades gracefully otherwise - confirmed 2026-09-17).
    grep -v '^pylibmc' "$requirements" > "$SCRIPT_DIR/.requirements-filtered.txt"
    pip_install -r "$SCRIPT_DIR/.requirements-filtered.txt"
    rm -f "$SCRIPT_DIR/.requirements-filtered.txt"
else
    echo "Warning: Server/artemis/requirements.txt not found (set FGO_INSTALL_ROOT in $ENV_FILE first for the exact pinned versions) - installing a known-good minimal set instead." >&2
    pip_install pyyaml "sqlalchemy==1.4.46" aiomysql "starlette==0.52.1" uvicorn pycryptodome coloredlogs
fi
# Needed by the fgo title module but missing from artemis's own
# requirements.txt (confirmed 2026-09-17) - always ensure it's present.
pip_install msgpack
# aiomysql (unpinned in requirements.txt) breaks against current PyMySQL:
# aiomysql imports converters.escape_dict/escape_sequence/escape_string,
# which PyMySQL 1.1+ removed. Confirmed working pair: aiomysql 0.3.2 +
# PyMySQL 1.0.x (confirmed 2026-09-17). Pin after the main install so this
# always wins regardless of what pip's resolver picked above.
pip_install "PyMySQL<1.1"

set_env_value FGO_PYTHON "$VENV_DIR/bin/python"

echo
echo "Done. $ENV_FILE now points FGO_PYTHON at $VENV_DIR/bin/python."
if ! grep -q '^FGO_INSTALL_ROOT="[^"]' "$ENV_FILE"; then
    echo "Still needed: edit $ENV_FILE (or re-run with --install-root) to set FGO_INSTALL_ROOT."
fi
if ! grep -q '^WINEPREFIX="[^"]' "$ENV_FILE"; then
    echo "Still needed for fgo-launcher.sh: edit $ENV_FILE (or re-run with --wineprefix) to set WINEPREFIX."
fi

# Also sync the server's own port/database config (core.yaml + fgo-launcher.json)
# if the install is already in place - harmless no-op if it's already correct,
# and fixes a fresh/regenerated install's stale placeholder values (e.g. a
# database port nothing actually listens on) without a separate manual step.
# Silently skipped if the install isn't at FGO_INSTALL_ROOT yet.
if [ -n "$current_install_root" ] && [ -f "$current_install_root/Server/tools/fgo_server_config.py" ]; then
    echo
    "$SCRIPT_DIR/fix-server-config.sh"
fi
