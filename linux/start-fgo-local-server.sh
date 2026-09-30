#!/usr/bin/env bash
# Linux port of payload/Server/Start-FGOLocalServer.ps1.
#
# The original dot-sources Server/ServerSettings.ps1, which isn't part of
# this repo (a base-install file, not shipped by the patch payload). Rather
# than guess its logic, this reuses Server/tools/fgo_server_config.py, which
# is in this repo and already reads the same host/ports from core.yaml and
# fgo-launcher.json for its own purposes.
#
# Difference from the original: the original only ever starts a *local*
# bundled MariaDB and assumes it's reachable at 127.0.0.1. This instead reads
# database.host from core.yaml, so a remote MariaDB is checked and used as-is
# without trying to spawn a local one on top of it.
#
# Usage: start-fgo-local-server.sh [server-host]
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
. "$SCRIPT_DIR/fgo-startup-checks.sh"

fgo_require_cmd "$FGO_PYTHON" flock curl
fgo_require_install_root

server_root="$FGO_INSTALL_ROOT/Server"
artemis_root="$server_root/artemis"
core_config="$artemis_root/config/core.yaml"
config_tool="$server_root/tools/fgo_server_config.py"
state_dir="$server_root/state"
log_dir="$FGO_INSTALL_ROOT/logs"

for required in "$artemis_root" "$config_tool" "$core_config"; do
    [ -e "$required" ] || fgo_die "Local server component is missing: $required" 2
done

mkdir -p "$state_dir" "$log_dir"

exec 9>"$state_dir/server-start.lock"
if ! flock -n 9; then
    fgo_die "Another launcher is starting the server, or the state folder is not writable. Wait for the current startup to finish." 1
fi

fgo_writable_layout "$FGO_INSTALL_ROOT"

settings_json=$("$FGO_PYTHON" "$config_tool" show) || fgo_die "Could not read server configuration: $settings_json" 1
read -r SRV_HOST SRV_ADDRESS SRV_HTTP SRV_BILLING SRV_AIME SRV_DATABASE <<EOF
$("$FGO_PYTHON" -c '
import json, sys
d = json.loads(sys.argv[1])
print(d["host"], d["address"], d["http"], d["billing"], d["aime"], d["database"])
' "$settings_json")
EOF

server_host=${1:-$SRV_HOST}
case "$server_host" in
    ""|auto|local|localhost|127.0.0.1) server_host=192.168.100.1 ;;
esac

already_open=0
fgo_tcp_open 127.0.0.1 "$SRV_HTTP" 1 && already_open=1
hostname_output=$("$FGO_PYTHON" "$SCRIPT_DIR/tools/set_core_hostname.py" "$core_config" "$server_host" "$already_open" 2>&1)
hostname_rc=$?
case $hostname_rc in
    0) : ;;
    3) fgo_die "$hostname_output" 1 ;;
    *) fgo_die "Could not update the ARTEMiS hostname in $core_config: $hostname_output" 1 ;;
esac

db_host=$("$FGO_PYTHON" -c '
import sys, yaml
core = yaml.safe_load(open(sys.argv[1], encoding="utf-8"))
print(core.get("database", {}).get("host") or "127.0.0.1")
' "$core_config")

case "$db_host" in
    127.0.0.1|localhost)
        if ! fgo_tcp_open "$db_host" "$SRV_DATABASE" 1; then
            maria_root="$server_root/mariadb-10.11.16-winx64"
            maria_daemon="$maria_root/bin/mariadbd.exe"
            maria_ini="$server_root/mariadb.ini"
            maria_data="$server_root/data/mariadb"
            [ -f "$maria_daemon" ] || fgo_die "core.yaml points the database at $db_host but nothing is listening there, and the bundled $maria_daemon is missing. If your database is on another machine, set database.host in $core_config to that machine's address instead." 2
            fgo_require_cmd setsid "${FGO_WINE:-wine}"
            [ -n "${WINEPREFIX:-}" ] || fgo_warn "WINEPREFIX is not set; wine will use its default prefix (~/.wine), which is probably not this game's prefix."
            db_out="$log_dir/mariadb-stdout.log"; db_err="$log_dir/mariadb-stderr.log"
            fgo_spawn_detached "$state_dir/mariadb.pid" \
                "${FGO_WINE:-wine}" "$maria_daemon" "--defaults-file=$maria_ini" "--basedir=$maria_root" \
                "--datadir=$maria_data" "--pid-file=$state_dir/mariadb-engine.pid" \
                "--log-error=$log_dir/mariadb.log" --console >"$db_out" 2>"$db_err" </dev/null
            fgo_wait_tcp "$db_host" "$SRV_DATABASE" 20 || fgo_die "The local database did not start. See $db_err and $log_dir/mariadb.log" 1
        fi
        ;;
    *)
        fgo_log "Database configured at $db_host:$SRV_DATABASE (remote) - not starting a local MariaDB."
        fgo_wait_tcp "$db_host" "$SRV_DATABASE" 5 || fgo_die "Cannot reach the configured database at $db_host:$SRV_DATABASE. Check that MariaDB is running there and reachable from this machine (firewall, bind-address)." 1
        ;;
esac

# Unlike the original's Assert-FgoPortOwner (which used the WMI cmdlets that
# don't work under Wine), this doesn't try to identify who owns each port -
# process identity for a Wine-hosted binary doesn't map cleanly to
# /proc/<pid>/exe anyway. It relies on the health check below as the safety
# net for the http port, and on Wait-TcpPort simply timing out for the rest.
get_health() { curl -fsS --max-time 3 "http://127.0.0.1:$SRV_HTTP/" 2>/dev/null; }

service_ok=0
if fgo_tcp_open 127.0.0.1 "$SRV_HTTP" 1; then
    if get_health | grep -q 'Service OK'; then
        service_ok=1
    else
        fgo_die "Port $SRV_HTTP is already occupied by another program. Stop it before starting the FGO local server." 1
    fi
fi

if [ "$service_ok" -ne 1 ]; then
    if ! py_check=$("$FGO_PYTHON" -I -c "import yaml,sqlalchemy,aiomysql,uvicorn,starlette,Crypto" 2>&1); then
        fgo_die "$FGO_PYTHON is missing required packages: $py_check. Install them with: $FGO_PYTHON -m pip install pyyaml sqlalchemy aiomysql uvicorn starlette pycryptodome (or set FGO_PYTHON to a venv that already has them)" 1
    fi
    # FGO_BILLING_TLS10=1 lets amdaemon's accounting report through the billing
    # port (TLS 1.0, refused by OpenSSL 3 at Python's default security level).
    tls_mode=revert; [ "${FGO_BILLING_TLS10:-0}" = "1" ] && tls_mode=apply
    "$FGO_PYTHON" "$SCRIPT_DIR/tools/patch_billing_tls.py" "$tls_mode" "$artemis_root/index.py" \
        || fgo_warn "Could not $tls_mode the billing TLS 1.0 patch (see above)."
    server_out="$log_dir/artemis-stdout.log"; server_err="$log_dir/artemis-stderr.log"
    ( cd "$artemis_root" && fgo_spawn_detached "$state_dir/artemis.pid" "$FGO_PYTHON" index.py --config config \
        >"$server_out" 2>"$server_err" </dev/null )
fi

for port in "$SRV_HTTP" "$SRV_BILLING" "$SRV_AIME"; do
    if ! fgo_wait_tcp 127.0.0.1 "$port" 30; then
        # The last stderr line is usually the actual cause (e.g. an ImportError
        # from an incompletely copied install).
        last_error=$(grep -v '^[[:space:]]*$' "$log_dir/artemis-stderr.log" 2>/dev/null | tail -n 1)
        fgo_die "ARTEMiS did not open required port $port${last_error:+: $last_error}. See $log_dir/artemis-stderr.log" 1
    fi
done

if ! get_health | grep -q 'Service OK'; then
    fgo_die "The local ALL.Net service did not pass its health check." 1
fi

fgo_log "FGO local server is ready at $server_host ($SRV_HTTP/$SRV_BILLING/$SRV_AIME)."
