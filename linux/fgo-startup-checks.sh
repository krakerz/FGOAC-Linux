# Port of payload/App/FGO_StartupChecks.ps1. Source, don't execute.
#
# The original used icacls to repair ACLs and a native DLL to detach child
# process stdio handles from the parent. Neither applies on Linux: file
# ownership under a Wine prefix is already the invoking user's, and a
# backgrounded process (`cmd &` with redirected stdio) is detached from the
# caller's pipes by construction, so there is nothing to "protect" here.

fgo_writable_layout() {
    local root=$1
    local folders=(App AMFS GameData DEVICE DEVICE/runtime DEVICE/print \
        logs Server/state Server/artemis/config Server/data/mariadb)
    local rel path probe
    for rel in "${folders[@]}"; do
        path="$root/$rel"
        mkdir -p "$path" 2>/dev/null || fgo_die "Cannot create $path. Check the permissions of the Wine prefix and that the drive is not full." 4
        probe="$path/.fgo-write-$$-$RANDOM"
        if ! ( : > "$probe" ) 2>/dev/null; then
            fgo_die "Cannot write to $path. Check that you own this Wine prefix (chown/chmod) and that the drive is not full or mounted read-only." 4
        fi
        rm -f "$probe"
    done
    local files=(App/fgo-launcher.json App/deck.json App/segatools.ini \
        Server/mariadb.ini Server/artemis/config/core.yaml)
    for rel in "${files[@]}"; do
        path="$root/$rel"
        [ -f "$path" ] && chmod u+rw "$path" 2>/dev/null
    done
}
