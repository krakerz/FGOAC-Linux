#!/usr/bin/env bash
# Linux port of payload/Server/Stop-FGOLocalServerWhenIdle.ps1.
#
# The original discovers the game/frontend processes system-wide by name via
# WMI (Get-CimInstance Win32_Process), because on Windows it can't otherwise
# get a direct handle on a process started by a separate launcher chain. We
# don't have that problem: fgo-launcher.sh starts wine itself and records the
# actual game PID in Server/state/game.pid, so this just waits on real PIDs
# instead of re-discovering them by name/path.
#
# Usage: stop-fgo-local-server-when-idle.sh LAUNCHER_PID
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
fgo_require_install_root

launcher_pid=${1:?Usage: stop-fgo-local-server-when-idle.sh LAUNCHER_PID}
game_pidfile="$FGO_INSTALL_ROOT/Server/state/game.pid"
log="$FGO_INSTALL_ROOT/logs/server-control.log"
mkdir -p "$(dirname "$log")"

while fgo_pid_alive "$launcher_pid"; do sleep 1; done

if [ -f "$game_pidfile" ]; then
    game_pid=$(cat "$game_pidfile")
    while fgo_pid_alive "$game_pid"; do sleep 1; done
fi

# A relaunch kills the previous game and starts its own launcher; keep the
# server up for that newer session instead of stopping it underneath it.
while pgrep -f "bash $SCRIPT_DIR/fgo-launcher\.sh" >/dev/null 2>&1; do sleep 2; done

{
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Launcher and game exited; stopping this installation's server (launcher=$launcher_pid)."
    "$SCRIPT_DIR/stop-fgo-local-server.sh"
} >>"$log" 2>&1
