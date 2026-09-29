#!/usr/bin/env bash
# Keeps Server/artemis/config/core.yaml and App/fgo-launcher.json in sync
# for a given install, using Server/tools/fgo_server_config.py's own "apply"
# command - already part of the distribution, not new logic. Wraps it with
# sensible defaults so a fresh/regenerated install (which can ship stale
# placeholder values, e.g. a leftover database port nothing listens on) can
# be fixed in one command instead of retyping the full fgo_server_config.py
# invocation each time.
#
# Also fixes what that tool does NOT manage: core.yaml's database.host/
# username/password/name. fgo_server_config.py only ever touches the four
# service *ports* - a fresh/regenerated install silently reverts to the
# factory default (the bundled local MariaDB at 127.0.0.1) with no way to
# reapply a remote MariaDB setup short of hand-editing the YAML. Set
# FGO_DB_* below once in fgo.env and this survives every future reset.
#
# Usage: fix-server-config.sh [--show]
#   [--host auto|local|<ip>] [--http PORT] [--billing PORT] [--aime PORT] [--database PORT]
#   [--db-host HOST] [--db-user USER] [--db-password PASS] [--db-name NAME]
#   --show    print the install's current effective config and exit (no changes)
#
# Defaults come from fgo.env (FGO_SERVER_*, FGO_DB_*) if set, else the
# values already established for this project (see fgo.env.example).
# --host is about where the *game client* looks for the ARTEMiS server
# (local LAN vs a remote deployment) - a separate, unrelated concern from
# --db-host (where the MariaDB backing that server actually lives).
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
fgo_require_cmd "$FGO_PYTHON"

[ -n "${FGO_INSTALL_ROOT:-}" ] || fgo_die "FGO_INSTALL_ROOT is not set - see fgo.env" 1
tool_path="$FGO_INSTALL_ROOT/Server/tools/fgo_server_config.py"
core_yaml_path="$FGO_INSTALL_ROOT/Server/artemis/config/core.yaml"
[ -f "$tool_path" ] || fgo_die "fgo_server_config.py not found at $tool_path" 1

if [ "${1:-}" = "--show" ]; then
    "$FGO_PYTHON" "$tool_path" show
    exit 0
fi

host=${FGO_SERVER_HOST:-auto}
http=${FGO_SERVER_HTTP_PORT:-8777}
billing=${FGO_SERVER_BILLING_PORT:-9999}
aime=${FGO_SERVER_AIME_PORT:-7777}
database=${FGO_SERVER_DB_PORT:-3306}
db_host=${FGO_DB_HOST:-}
db_user=${FGO_DB_USER:-}
db_password=${FGO_DB_PASSWORD:-}
db_name=${FGO_DB_NAME:-}

while [ $# -gt 0 ]; do
    case "$1" in
        --host) host=$2; shift 2 ;;
        --http) http=$2; shift 2 ;;
        --billing) billing=$2; shift 2 ;;
        --aime) aime=$2; shift 2 ;;
        --database) database=$2; shift 2 ;;
        --db-host) db_host=$2; shift 2 ;;
        --db-user) db_user=$2; shift 2 ;;
        --db-password) db_password=$2; shift 2 ;;
        --db-name) db_name=$2; shift 2 ;;
        *) fgo_die "Unknown option: $1" 1 ;;
    esac
done

fgo_log "Applying server config to $FGO_INSTALL_ROOT: host=$host http=$http billing=$billing aime=$aime database=$database"
"$FGO_PYTHON" "$tool_path" apply --host "$host" --http "$http" --billing "$billing" --aime "$aime" --database "$database"

if [ -n "$db_host$db_user$db_password$db_name" ]; then
    fgo_log "Applying database connection (host/username/password/name) to core.yaml..."
    "$FGO_PYTHON" "$SCRIPT_DIR/tools/set_core_database.py" "$core_yaml_path" "$db_host" "$db_user" "$db_password" "$db_name"
fi
fgo_log "Done."
