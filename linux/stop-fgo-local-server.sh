#!/usr/bin/env bash
# New script: the original payload/Server/Stop-FGOLocalServer.ps1 isn't part
# of this repo (a base-install file we don't have the source for), so this
# is a fresh Linux equivalent rather than a port. It only stops what
# start-fgo-local-server.sh itself started, tracked via PID files under
# Server/state - never a remote database.
#
# The original's local-MariaDB stop sends a clean `mariadb-admin ... shutdown`
# using a hardcoded root password from the base install. That password isn't
# reproduced here (not something to copy into a new script file even though
# it's only ever reachable at 127.0.0.1); this sends SIGTERM instead, which
# mariadbd also treats as a graceful shutdown request. Because
# start-fgo-local-server.sh starts both processes via `setsid`, each pid is
# its own process group leader, so killing the group (not just the pid)
# takes any descendants with it - the Linux equivalent of the original's
# Stop-ProcessTree.
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
fgo_require_install_root

state_dir="$FGO_INSTALL_ROOT/Server/state"

stop_pidfile() {
    local name=$1 pidfile=$2 pid
    [ -f "$pidfile" ] || return 0
    pid=$(cat "$pidfile")
    if fgo_pid_alive "$pid"; then
        fgo_log "Stopping $name (pid $pid)..."
        kill -TERM -- "-$pid" 2>/dev/null || kill "$pid" 2>/dev/null
        for _ in $(seq 1 20); do
            fgo_pid_alive "$pid" || break
            sleep 0.5
        done
        fgo_pid_alive "$pid" && { kill -9 -- "-$pid" 2>/dev/null || kill -9 "$pid" 2>/dev/null; }
    fi
    rm -f "$pidfile"
}

stop_pidfile "ARTEMiS local server" "$state_dir/artemis.pid"
stop_pidfile "local MariaDB" "$state_dir/mariadb.pid"

# An ARTEMiS started from another install folder (e.g. an old copy kept next to
# a fresh one) isn't in this install's pid file but still holds the same ports,
# and fgo_server_config.py then refuses to save with "Stop the local server".
# Stop it too - only when it really is ARTEMiS (index.py run from a
# .../Server/artemis folder), never whatever else might own a port.
config_tool="$FGO_INSTALL_ROOT/Server/tools/fgo_server_config.py"
if ports=$("$FGO_PYTHON" -c '
import json, subprocess, sys
d = json.loads(subprocess.run([sys.executable, sys.argv[1], "show"], capture_output=True, text=True, check=True).stdout)
print(d["http"], d["billing"], d["aime"])
' "$config_tool" 2>/dev/null); then
    for port in $ports; do
        for pid in $(ss -ltnpH "sport = :$port" 2>/dev/null | grep -o 'pid=[0-9]*' | cut -d= -f2 | sort -u); do
            cwd=$(readlink "/proc/$pid/cwd" 2>/dev/null) || continue
            case "$cwd" in */Server/artemis) ;; *) continue ;; esac
            tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null | grep -q 'index\.py' || continue
            fgo_log "Stopping ARTEMiS from another install on port $port (pid $pid, $cwd)..."
            kill -TERM "$pid" 2>/dev/null
            for _ in $(seq 1 20); do
                fgo_pid_alive "$pid" || break
                sleep 0.5
            done
            fgo_pid_alive "$pid" && kill -9 "$pid" 2>/dev/null
        done
    done
fi
rm -f "$state_dir/server-start.lock"
fgo_log "Local server stopped."
