# Shared helpers for the FGOAC scooby Linux scripts. Source, don't execute.
#
# Required env:
#   FGO_INSTALL_ROOT   Linux path to the folder holding App/ and Server/
#                       (e.g. the drive_c path inside your Wine prefix).
# Optional env:
#   FGO_WINE           wine binary to use (default: wine)
#   WINEPREFIX          passed straight through to wine if set
#   FGO_PYTHON         python3 interpreter to use (default: python3) - point
#                       this at a venv if your system Python is externally
#                       managed (e.g. Arch/CachyOS's PEP 668 restriction)
#
# Instead of exporting the above by hand before every run, put them in
# linux/fgo.env (run linux/setup.sh once to create it, plus a venv) - every
# script here sources it automatically. Values there are authoritative: they
# override anything already exported in the calling shell. Point
# FGO_CONFIG_FILE at a different file to use a config outside the project
# folder instead. See fgo.env.example for the format.

set -uo pipefail

FGO_LINUX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FGO_CONFIG_FILE=${FGO_CONFIG_FILE:-$FGO_LINUX_DIR/fgo.env}
if [ -f "$FGO_CONFIG_FILE" ]; then
    . "$FGO_CONFIG_FILE"
fi
# fgo.env's assignments aren't exported by sourcing; without this wine never
# saw WINEPREFIX and silently ran the game in ~/.wine.
[ -n "${WINEPREFIX:-}" ] && export WINEPREFIX

: "${FGO_PYTHON:=python3}"

fgo_log() { printf '%s\n' "$*"; }
fgo_warn() { printf 'WARNING: %s\n' "$*" >&2; }
fgo_die() { printf 'ERROR: %s\n' "$1" >&2; exit "${2:-1}"; }

fgo_require_cmd() {
    local missing=()
    for cmd in "$@"; do
        command -v "$cmd" >/dev/null 2>&1 || missing+=("$cmd")
    done
    if [ "${#missing[@]}" -gt 0 ]; then
        fgo_die "Missing required command(s): ${missing[*]}"
    fi
}

fgo_require_install_root() {
    if [ -z "${FGO_INSTALL_ROOT:-}" ]; then
        fgo_die "FGO_INSTALL_ROOT is not set. Export it to the Linux path holding App/ and Server/ (e.g. the game folder inside your Wine prefix's drive_c)." 2
    fi
    if [ ! -d "$FGO_INSTALL_ROOT/App" ] || [ ! -d "$FGO_INSTALL_ROOT/Server" ]; then
        fgo_die "FGO_INSTALL_ROOT ($FGO_INSTALL_ROOT) does not look like an FGO Arcade install: App/ or Server/ is missing." 2
    fi
}

# tcp connect check; returns 0 if a listener answers within timeout seconds.
fgo_tcp_open() {
    local host=$1 port=$2 timeout=${3:-2}
    timeout "$timeout" bash -c "exec 3<>\"/dev/tcp/${host}/${port}\"" 2>/dev/null
}

fgo_wait_tcp() {
    local host=$1 port=$2 timeout=$3
    local deadline=$(( $(date +%s) + timeout ))
    while [ "$(date +%s)" -lt "$deadline" ]; do
        fgo_tcp_open "$host" "$port" 1 && return 0
        sleep 0.25
    done
    return 1
}

fgo_pid_alive() {
    [ -n "${1:-}" ] && kill -0 "$1" 2>/dev/null
}

# Starts "$@" detached in a new session (survives this shell exiting/SIGHUP)
# and writes the actual long-running process's PID to $1 - NOT `$!`, which
# names something else here (see below). Apply stdio redirections on the
# call to fgo_spawn_detached itself, e.g.:
#   fgo_spawn_detached "$pidfile" mycommand --arg >"$out" 2>"$err" </dev/null
#
# `$!` right after `setsid CMD &` is unreliable: a backgrounded job is
# already its own process-group leader under bash job control, so setsid(2)
# can't apply to that same process (EPERM) and setsid(1) forks once more to
# get around it - `$!` then names that short-lived wrapper, one level above
# the real CMD in the process tree, not CMD itself. Confirmed with
# util-linux 2.42.3 on 2026-09-17: a pidfile written from plain `$!` named a
# process that was not the one actually holding the port, so stopping "by
# pid" silently stopped nothing. Rather than detect the real pid from
# outside (racy - the wrapper's fork isn't instant), have the process report
# its own pid from inside the new session: `bash -c 'echo $$ >pidfile; exec
# "$@"'` runs as whichever process ultimately calls exec, after any of
# setsid's own forking has already resolved, so `$$` there is always correct.
#
# Also closes fd 9 before the final exec: start-fgo-local-server.sh holds
# the server-start lock open on fd 9 (`exec 9>...`) for its own duration,
# but `exec` doesn't set FD_CLOEXEC by default, so the detached process
# would otherwise inherit and keep that fd open indefinitely - confirmed
# 2026-09-17, the artemis server process ended up holding the lock forever,
# making every later `flock -n` attempt fail with "another launcher is
# starting the server" even though the original script had long since
# exited. Harmless if fd 9 wasn't open in the first place (bash's `exec N>&-`
# on an already-closed fd is a silent no-op, not an error).
fgo_spawn_detached() {
    local pidfile=$1; shift
    setsid bash -c 'exec 9>&-; echo $$ > "$1"; shift; exec "$@"' _ "$pidfile" "$@" &
}

# Run a Windows binary from the install under Wine. Requires WINEPREFIX to be
# set by the caller (or already exported) since we never guess a prefix path.
fgo_wine() {
    local wine_bin=${FGO_WINE:-wine}
    if [ -z "${WINEPREFIX:-}" ]; then
        fgo_warn "WINEPREFIX is not set; wine will use its default prefix (~/.wine), which is probably not this game's prefix."
    fi
    "$wine_bin" "$@"
}
