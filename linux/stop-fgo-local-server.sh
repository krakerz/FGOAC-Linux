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
rm -f "$state_dir/server-start.lock"
fgo_log "Local server stopped."
