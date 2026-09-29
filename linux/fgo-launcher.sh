#!/usr/bin/env bash
# Linux port of payload/App/FGO_Launcher.ps1.
#
# Dropped entirely (Windows-only, no Linux equivalent needed):
#   - ConvertTo-WindowsCommandLineArgument: only existed because PS 5.1's
#     ProcessStartInfo.Arguments needs one pre-quoted string. `wine prog "$@"`
#     gets a real argv array from execve and needs no manual quoting.
#   - Protect-FgoChildProcessStreams: a background process started with `&`
#     and redirected stdio is already detached from this script's pipes.
#   - The async stdout/stderr pump: PowerShell's transcript buffered native
#     debug output until the process exited; a plain shell redirect doesn't.
#   - The DirectX UserGpuPreferences registry key: replaced below with the
#     Linux/Mesa and NVIDIA PRIME env-var equivalents.
#   - __COMPAT_LAYER's DISABLEDXMAXIMIZEDWINDOWEDMODE shim: real Windows
#     AppCompat, which Wine doesn't implement. Passed through as a no-op for
#     parity; borderless behavior under Wine may differ from real Windows.
#
# Env overrides (all optional): FGO_INPUT_MODE, FGO_DISPLAY_MODE,
# FGO_MONITOR_DEVICE, FGO_RESOLUTION_WIDTH, FGO_RESOLUTION_HEIGHT,
# FGO_TARGET_FPS, FGO_RENDER_SCALE.
# Flags: --windowed --skip-server-check --chinese --experimental-audio --check-only
set -uo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"
. "$SCRIPT_DIR/fgo-startup-checks.sh"

fgo_require_cmd "$FGO_PYTHON"
fgo_require_install_root

opt_windowed=0 opt_skip_server_check=0 opt_chinese=0 opt_experimental_audio=0 opt_check_only=0
for arg in "$@"; do
    case "$arg" in
        --windowed) opt_windowed=1 ;;
        --skip-server-check) opt_skip_server_check=1 ;;
        --chinese) opt_chinese=1 ;;
        --experimental-audio) opt_experimental_audio=1 ;;
        --check-only) opt_check_only=1 ;;
        *) fgo_die "Unknown option: $arg" 1 ;;
    esac
done

game_root="$FGO_INSTALL_ROOT/App"
install_root="$FGO_INSTALL_ROOT"
amfs_root="$install_root/AMFS"
base_ini="$game_root/segatools.ini"
launcher_config_path="$game_root/fgo-launcher.json"
main_config_path="$game_root/config.json"
inject_path="$game_root/inject.exe"
hook_path="$game_root/fgohook.dll"
pending_hook_path="$game_root/fgohook.pending.dll"
gl_compat_path="$game_root/fgoglcompat.dll"
# Self-heal a fresh/regenerated install: ago.exe calls NVIDIA-only OpenGL
# bindless-buffer extensions unconditionally, and on non-NVIDIA (Mesa) GPUs
# that's a null-pointer crash a few seconds in unless the distribution's own
# "Legacy" compat layer is deployed to App/ - see the project's NOTES.md
# 2026-09-29 entry. Only auto-deploy it if NEITHER compat layer is already
# present (never overwrite a deliberate amd-shim/opengl32.dll choice).
if [ ! -f "$gl_compat_path" ] && [ ! -f "$game_root/opengl32.dll" ] && [ -f "$install_root/compat/fgoglcompat.dll" ]; then
    cp "$install_root/compat/fgoglcompat.dll" "$gl_compat_path"
    fgo_log "GPU compat: deployed compat/fgoglcompat.dll (Legacy layer) to App/ - fresh install had neither compat layer."
fi

# Self-heal: cards with native GL_ARB_bindless_texture support (check with
# `glxinfo | grep bindless`) still need a Mesa driconf override on top of the
# compat layer above, or ago.exe hits a GLSL compile error Mesa rejects by
# default - see the root README's "GPU compatibility" section. ~/.drirc is a
# system-wide per-user file that can hold other games' own stanzas, so this
# only ever adds ours if missing (parses the existing XML, preserving
# everything else byte-for-byte) - never overwrites the file, and leaves it
# alone entirely if it isn't recognizable driconf XML.
"$FGO_PYTHON" "$SCRIPT_DIR/tools/ensure_drirc.py" 2>&1 | while IFS= read -r drirc_line; do fgo_log "$drirc_line"; done

# Self-heal: modern Wine (11.0+, the only branches this game runs on) links
# wined3d.dll's own Vulkan backend against libvkd3d-*.dll - a real, load-time
# dependency, not optional. A Proton build ships those PE DLLs in its own
# files/share/default_pfx template, but only Steam's own Proton "run"/setup
# step copies that template into a fresh prefix; calling this build's wine
# binary directly (as this script does) never does that copy at all, so a
# prefix that's never been launched through Steam itself is permanently
# missing them. Symptom without this: ago.exe fails at its very first d3d9
# import (wined3d.dll -> libvkd3d-*.dll not found, status c0000135) and
# exits within a second or a few seconds in - confirmed on two separate
# wine-11.0 builds/prefixes (Proton-GE and Proton-CachyOS) on 2026-09-29.
# Only fills in what's missing - never overwrites a real vkd3d install.
proton_root="${FGO_WINE%/files/bin/wine}"
if [ "$proton_root" != "${FGO_WINE:-}" ] && [ -d "$proton_root/files/share/default_pfx" ]; then
    for arch_dir in system32 syswow64; do
        default_dir="$proton_root/files/share/default_pfx/drive_c/windows/$arch_dir"
        [ -d "$default_dir" ] || continue
        target_dir="$WINEPREFIX/drive_c/windows/$arch_dir"
        mkdir -p "$target_dir"
        for dll in "$default_dir"/libvkd3d-*.dll; do
            [ -e "$dll" ] || continue
            dll_name=$(basename "$dll")
            if [ ! -f "$target_dir/$dll_name" ]; then
                cp "$dll" "$target_dir/$dll_name"
                fgo_log "Wine compat: copied $dll_name into the prefix's $arch_dir (this Proton build's own default_pfx was never applied to this prefix)."
            fi
        done
    done
fi

# Keep the shader cache (App/shader-cache-rN/ - the folder name's numeric
# suffix is tied to the game version) outside the install so a fresh/
# regenerated install doesn't force a ~45-90s cold shader recompile every
# time - first compile after any install regen is still cold once, but
# every launch after that reuses the persistent copy via a symlink.
shader_cache_store=${FGO_SHADER_CACHE_DIR:-$HOME/.cache/fgoac-linux/shader-cache}
mkdir -p "$shader_cache_store"
# A real (non-symlink) cache dir the game just created - move it out and
# symlink it back, so this and every future run share the persistent copy.
for real_cache_dir in "$game_root"/shader-cache-r*; do
    [ -d "$real_cache_dir" ] && [ ! -L "$real_cache_dir" ] || continue
    name=$(basename "$real_cache_dir")
    if [ -e "$shader_cache_store/$name" ]; then
        rsync -a --remove-source-files "$real_cache_dir/" "$shader_cache_store/$name/" 2>/dev/null || cp -rn "$real_cache_dir/." "$shader_cache_store/$name/"
        rm -rf "$real_cache_dir"
    else
        mv "$real_cache_dir" "$shader_cache_store/$name"
    fi
    ln -s "$shader_cache_store/$name" "$real_cache_dir"
    fgo_log "Shader cache: moved App/$name to $shader_cache_store and symlinked it back."
done
# A persistent cache from a previous run/regen, but this fresh App/ has no
# cache dir (real or symlinked) yet at all - relink it proactively so the
# very first launch after a regen is warm too, not just the second one.
for stored_cache_dir in "$shader_cache_store"/shader-cache-r*; do
    [ -d "$stored_cache_dir" ] || continue
    name=$(basename "$stored_cache_dir")
    [ -e "$game_root/$name" ] || ln -s "$stored_cache_dir" "$game_root/$name"
done
locale_hook_path="$game_root/Tools/Locale_Remulator/LRHookx64.dll"
audio_hook_path="$game_root/FGOAudio.dll"
chinese_hook_path="$game_root/zh/fgozh.dll"
pending_chinese_hook_path="$game_root/zh/fgozh.pending.dll"
ago_path="$game_root/ago.exe"
device_root="$install_root/DEVICE"
runtime_directory="$device_root/runtime"
log_directory="$install_root/logs"
runtime_ini="$runtime_directory/segatools.runtime.ini"
amdaemon_main_config="$runtime_directory/amdaemon_main.json"
inject_live_log_path="$log_directory/fgo-inject-live.log"
state_dir="$install_root/Server/state"

fgo_log "FGO Arcade safe launcher (Linux)"

required_files=("$base_ini" "$launcher_config_path" "$inject_path" "$hook_path" \
    "$main_config_path" "$locale_hook_path" "$ago_path" "$game_root/am/amdaemon.exe" \
    "$amfs_root/ICF1" "$amfs_root/ICF2")
missing=()
for f in "${required_files[@]}"; do [ -e "$f" ] || missing+=("$f"); done
if [ "${#missing[@]}" -gt 0 ]; then
    fgo_die "Required files are missing:"$'\n'"$(printf '%s\n' "${missing[@]}")" 2
fi

# Best-effort audio check: PipeWire/PulseAudio if available, else skip (the
# original only aborted when it *successfully* enumerated zero endpoints).
if command -v pactl >/dev/null 2>&1; then
    if [ -z "$(pactl list short sinks 2>/dev/null)" ]; then
        fgo_die "No active audio output device was found (pactl list short sinks was empty). Connect/enable your output device before launching FGO." 5
    fi
elif command -v aplay >/dev/null 2>&1; then
    if ! aplay -l >/dev/null 2>&1; then
        fgo_die "No active audio output device was found (aplay -l failed)." 5
    fi
fi

eval "$("$FGO_PYTHON" "$SCRIPT_DIR/tools/read_launcher_config.py" "$launcher_config_path" "$main_config_path")"

fgo_writable_layout "$install_root"

if ! env_output=$(bash "$SCRIPT_DIR/fgo-environment-check.sh" 2>&1); then
    fgo_die "Environment check failed:"$'\n'"$env_output" 15
fi

# --- Network plan: exact port of App/FGO_LocalNetwork.ps1's Get-FgoNetworkPlan ---
net_server_host_input=$CFG_SERVERHOST
net_local=0
case "$net_server_host_input" in
    ""|auto|local|localhost|127.0.0.1|192.168.100.1) net_local=1 ;;
esac
if [ "$net_local" -eq 1 ]; then
    net_server=192.168.100.1
    net_probe_host=127.0.0.1
    net_broadcast=127.0.0.1
else
    net_server=$net_server_host_input
    net_probe_host=$net_server_host_input
    net_broadcast=255.255.255.255
fi
net_cabinet=192.168.100.11
net_subnet=192.168.100.0
net_address_suffix=11
net_router_suffix=1
server_host=$net_server

export FGO_LOCAL_NETWORK=$net_local
export FGO_INSTALL_ROOT="$install_root"
export FGO_LOCAL_HTTP_PORT=$CFG_SERVERPORTS_HTTP
export FGO_LOCAL_BILLING_PORT=$CFG_SERVERPORTS_BILLING
export FGO_LOCAL_AIME_PORT=$CFG_SERVERPORTS_AIME

should_start_local_server=0
[ "$CFG_AUTOSTARTLOCALSERVER" = "1" ] && [ "$net_local" -eq 1 ] && should_start_local_server=1

if [ "$should_start_local_server" -eq 1 ] && [ "$opt_skip_server_check" -eq 0 ]; then
    fgo_log "Starting/checking the local ALL.Net, billing, AimeDB, and SDEJ capture services..."
    "$SCRIPT_DIR/start-fgo-local-server.sh" "$server_host" || fgo_die "The local FGO server could not start." 10
    # Independent watcher: survives this script being killed abruptly, and
    # stops only this installation's server. Tracks our own PIDs directly
    # instead of the original's WMI-based process discovery.
    setsid "$SCRIPT_DIR/stop-fgo-local-server-when-idle.sh" "$$" </dev/null >/dev/null 2>&1 &
    disown
fi

if [ "$opt_skip_server_check" -eq 0 ]; then
    closed_ports=()
    for port in "${CFG_REQUIREDPORTS[@]}"; do
        fgo_tcp_open "$net_probe_host" "$port" 2 || closed_ports+=("$port")
    done
    if [ "${#closed_ports[@]}" -gt 0 ]; then
        fgo_die "The configured server $server_host is not reachable on required port(s): ${closed_ports[*]}." 11
    fi
fi

effective_input_mode=${FGO_INPUT_MODE:-$CFG_INPUTMODE}
case "$effective_input_mode" in xinput|keyboard) ;; *) effective_input_mode=xinput ;; esac
effective_cabinet_mode=$CFG_CABINETMODE
case "$effective_cabinet_mode" in saved|server|satellite) ;; *) effective_cabinet_mode=saved ;; esac
effective_game_version=$CFG_GAMEVERSION
[ -z "$effective_game_version" ] && effective_game_version=11.00
[[ "$effective_game_version" =~ ^[0-9]{1,2}\.[0-9]{2}$ ]] || fgo_die "Invalid gameVersion '$effective_game_version'. Expected a value such as 11.00." 13

configured_display_mode=$CFG_DISPLAYMODE
case "$configured_display_mode" in
    windowed|borderless|exclusive) ;;
    *) [ "$CFG_WINDOWED" = "1" ] && configured_display_mode=windowed || configured_display_mode=exclusive ;;
esac
effective_display_mode=${FGO_DISPLAY_MODE:-}
if [ -z "$effective_display_mode" ]; then
    [ "$opt_windowed" -eq 1 ] && effective_display_mode=windowed || effective_display_mode=$configured_display_mode
fi
effective_windowed=1; [ "$effective_display_mode" = exclusive ] && effective_windowed=0
effective_framed=0; [ "$effective_display_mode" = windowed ] && effective_framed=1

effective_monitor_device=${FGO_MONITOR_DEVICE:-$CFG_MONITORDEVICE}
if [ -n "$effective_monitor_device" ] && [[ ! "$effective_monitor_device" =~ ^\\\\\.\\DISPLAY[0-9]+$ ]]; then
    fgo_die "Invalid monitor device '$effective_monitor_device'. Expected a Windows display device such as \\\\.\\DISPLAY1." 14
fi

effective_resolution_width=${FGO_RESOLUTION_WIDTH:-$CFG_RESOLUTIONWIDTH}
effective_resolution_height=${FGO_RESOLUTION_HEIGHT:-$CFG_RESOLUTIONHEIGHT}
if [ "$effective_resolution_width" -lt 480 ] || [ "$effective_resolution_width" -gt 7680 ] || \
   [ "$effective_resolution_height" -lt 480 ] || [ "$effective_resolution_height" -gt 7680 ]; then
    fgo_die "Invalid render resolution ${effective_resolution_width}x${effective_resolution_height}." 14
fi

# ago.exe's native render mode plus fgohook's exact-size patch; see FGO_Launcher.ps1
# for the original's reasoning (16:9 UI safe area extended to the requested aspect).
requested_aspect_left=$(( effective_resolution_width * 9 ))
requested_aspect_right=$(( effective_resolution_height * 16 ))
native_render_argument=-hdtv1080
if [ "$requested_aspect_left" -gt "$requested_aspect_right" ]; then
    native_render_argument=-wqhd
elif [ "$requested_aspect_left" -eq "$requested_aspect_right" ]; then
    if [ "$effective_resolution_width" -le 1280 ] && [ "$effective_resolution_height" -le 720 ]; then
        native_render_argument=-hdtv720
    elif [ "$effective_resolution_width" -lt 2560 ] && [ "$effective_resolution_height" -lt 1440 ]; then
        native_render_argument=-hdtv1080
    else
        native_render_argument=-wqhd
    fi
elif [ "$effective_resolution_width" -ge 2560 ]; then
    native_render_argument=-wqxga
else
    native_render_argument=-wuxga
fi

configured_target_fps=$CFG_TARGETFPS
case "$configured_target_fps" in 60|90|120|144) ;; *) configured_target_fps=60 ;; esac
requested_target_fps=${FGO_TARGET_FPS:-$configured_target_fps}
effective_target_fps=$requested_target_fps
if [ "$effective_target_fps" -gt 60 ]; then
    fgo_warn "High-FPS engine scheduling is suspended after UI/touch regressions; using native 60 FPS."
    effective_target_fps=60
fi

use_audio_hook=0
[ "$opt_experimental_audio" -eq 1 ] && use_audio_hook=1
if [ "$CFG_AUDIOHOOK" = "1" ] && [ "$opt_experimental_audio" -eq 0 ]; then
    fgo_warn "Ignored legacy audioHook setting; using built-in shared audio for 11.00."
fi
use_process_japanese_locale=$([ "$CFG_PROCESSJAPANESELOCALE" = "1" ] && echo 1 || echo 0)
use_wasapi_shared=$([ "$CFG_WASAPISHARED" = "1" ] && echo 1 || echo 0)
prefer_high_performance_gpu=1
[ "$CFG_PREFERHIGHPERFORMANCEGPU" = "0" ] && prefer_high_performance_gpu=0
enable_diagnostics=$([ "$CFG_DIAGNOSTICS" = "1" ] && echo 1 || echo 0)
enable_crypto_diagnostics=$([ "$CFG_CRYPTODIAGNOSTICS" = "1" ] && echo 1 || echo 0)
if [ -n "${CFG_PROTOCOLDIAGNOSTICS:-}" ]; then
    enable_protocol_diagnostics=$([ "$CFG_PROTOCOLDIAGNOSTICS" = "1" ] && echo 1 || echo 0)
else
    enable_protocol_diagnostics=$enable_crypto_diagnostics
fi

if [ "$use_audio_hook" -eq 1 ] && [ ! -f "$audio_hook_path" ]; then
    fgo_die "FGOAudio.dll is missing." 12
fi
[ "$use_audio_hook" -eq 1 ] && fgo_warn "FGOAudio.dll documents support for FGO 10.70/10.80. This $effective_game_version installation is unsupported by that optional hook, so it remains experimental."

mkdir -p "$runtime_directory" "$log_directory" "$device_root/print"
printf 'Waiting for the injector to start and stream live debug output...\r\n' > "$inject_live_log_path"
launch_log_path="$log_directory/fgo-last-launch.log"
: > "$launch_log_path"
cp -f "$base_ini" "$runtime_ini"

# The public setup package currently provides 10.80 ICF files while ago.exe
# was built from the 11.00 source snapshot; override the develop version so
# ALL.Net/billing advertise the same version as the game executable.
"$FGO_PYTHON" -c '
import json, sys
path, version = sys.argv[1], sys.argv[2]
json.dump({"credit": {"max_credit": 99}, "allnet_auth": {"develop_version": version}}, open(path, "w", encoding="utf-8"), indent=2)
' "$amdaemon_main_config" "$effective_game_version"

set_ini() { "$FGO_PYTHON" "$SCRIPT_DIR/tools/segatools_ini.py" "$runtime_ini" "$1" "$2" "$3"; }

set_ini vfs amfs "$amfs_root"
set_ini vfs option "$game_root/option"
set_ini vfs appdata "$install_root/GameData"
set_ini aime aimePath "$device_root/aime.txt"
set_ini printer mainFwPath "$device_root/printer_main_fw.bin"
set_ini printer paramFwPath "$device_root/printer_param_fw.bin"
set_ini printer dspFwPath "$device_root/printer_dsp_fw.bin"
set_ini keychip billingCa "$device_root/ca.crt"
set_ini keychip billingPub "$device_root/billing.pub"
set_ini misc nextProcessFilePath "$device_root/NextProcess.txt"

print_account=unassigned
print_name=""
aime_code=$(tr -d '[:space:]' < "$device_root/aime.txt" 2>/dev/null)
player_file="$install_root/Server/state/fgo-players.json"
if [ -f "$player_file" ] && [ -n "$aime_code" ]; then
    read -r print_account print_name <<PYEOF
$("$FGO_PYTHON" -c '
import json, re, sys
path, code = sys.argv[1], sys.argv[2]
players = json.loads(open(path, encoding="utf-8").read())
account, name = "unassigned", ""
for key, value in players.items():
    m = re.match(r"^aime:(\d+)$", key)
    if m and (str(value.get("auth_access_code","")) == code or str(value.get("access_code","")) == code):
        account, name = "aime-" + m.group(1), value.get("master_name","")
        break
print(account, name)
' "$player_file" "$aime_code")
PYEOF
fi
print_directory="$device_root/print/players/$print_account"
mkdir -p "$print_directory"
"$FGO_PYTHON" -c '
import json, sys
open(sys.argv[1], "w", encoding="utf-8").write(json.dumps({"account": sys.argv[2], "name": sys.argv[3]}))
' "$print_directory/player.json" "$print_account" "$print_name"
set_ini printer printerOutPath "$print_directory"
export FGO_PRINT_METADATA_ONLY=1

set_ini dns default "$server_host"
set_ini dns startupPort "$CFG_SERVERPORTS_HTTP"
set_ini dns billingPort "$CFG_SERVERPORTS_BILLING"
set_ini dns aimedbPort "$CFG_SERVERPORTS_AIME"
set_ini netenv enable 1
set_ini netenv routerSuffix "$net_router_suffix"
set_ini netenv addrSuffix "$net_address_suffix"
set_ini netenv broadcast "$net_broadcast"
set_ini keychip subnet "$net_subnet"
set_ini gfx windowed "$([ "$effective_windowed" -eq 1 ] && echo 1 || echo 0)"
set_ini gfx framed "$([ "$effective_framed" -eq 1 ] && echo 1 || echo 0)"
set_ini gfx width "$effective_resolution_width"
set_ini gfx height "$effective_resolution_height"
set_ini gfx logicalWidth "$effective_resolution_width"
set_ini gfx logicalHeight "$effective_resolution_height"
set_ini gfx preserveAspect 1
set_ini gfx monitor 0
set_ini gfx monitorDevice "$effective_monitor_device"
set_ini amvideo resolutionWidth "$effective_resolution_width"
set_ini amvideo resolutionHeight "$effective_resolution_height"
set_ini io4 mode "$effective_input_mode"
# io4 (the arcade-cabinet-I/O simulation) is unrelated to the fgozh.dll fix -
# see linux/NOTES or the project's NOTES.md ("ago.exe crashes/hangs on io4
# HID enumeration"). segatools' io4_hook_init() (common/board/io4.c) fakes
# the device's *existence* via a SetupAPI hook but implements only two IOCTLs
# (manufacturer/product string strings) - no real HID report descriptor.
# Real Windows tolerates that gracefully; Wine's dinput hidraw backend does
# not, and null-derefs while trying to enumerate it as a joystick. Setting
# FGO_IO4_ENABLE=0 sets `[io4] enable=0`, which segatools reads with
# GetPrivateProfileIntW(L"io4", L"enable", 1, ...) - default is enabled -
# and skips creating the phantom device entirely. Untested trade-off: io4
# also carries actual gameplay buttons (attack/NP/camera/stick), not just
# cabinet test/service/coin, so disabling it may leave the game running but
# uncontrollable rather than fixing this cleanly - worth testing, not yet
# confirmed safe.
if [ "${FGO_IO4_ENABLE:-1}" = "0" ]; then
    set_ini io4 enable 0
fi
set_ini touch remap 1
set_ini touch inputWidth 1920
set_ini touch inputHeight 1080
set_ini touch nativeCoordinates 0
set_ini system freeplay 0
set_ini clock timezone 0
set_ini clock daystart 0
set_ini clock startHour 0
set_ini clock startMinute 0
set_ini clock timewarp 0
set_ini clock writeable 0

# GetPrivateProfileStringW (used by segatools/fgohook) reads UTF-16; convert
# now that every Set-IniValue-equivalent edit above is done.
"$FGO_PYTHON" -c '
path = __import__("sys").argv[1]
data = open(path, encoding="utf-8").read()
open(path, "w", encoding="utf-16").write(data)
' "$runtime_ini"

export SEGATOOLS_CONFIG_PATH="$runtime_ini"
export FGO_TARGET_FPS=$effective_target_fps
unset FGO_DISABLE_FRAME_PACING FGO_REUSE_AMDAEMON

if [ "$enable_diagnostics" -eq 1 ]; then export FGO_EXIT_DIAGNOSTICS=1; else unset FGO_EXIT_DIAGNOSTICS; fi
if [ "$enable_protocol_diagnostics" -eq 1 ]; then export FGO_PROTOCOL_DIAGNOSTICS=1; else unset FGO_PROTOCOL_DIAGNOSTICS; fi
if [ "$enable_crypto_diagnostics" -eq 1 ]; then export BCRYPT_DUMP_ENABLED=1; else unset BCRYPT_DUMP_ENABLED; fi

# Linux/Mesa + NVIDIA PRIME equivalents of the original's per-exe
# DirectX UserGpuPreferences registry key (GpuPreference=2, "high performance").
if [ "$prefer_high_performance_gpu" -eq 1 ]; then
    export DRI_PRIME=${DRI_PRIME:-1}
    export __NV_PRIME_RENDER_OFFLOAD=${__NV_PRIME_RENDER_OFFLOAD:-1}
    export __GLX_VENDOR_LIBRARY_NAME=${__GLX_VENDOR_LIBRARY_NAME:-nvidia}
    export __VK_LAYER_NV_optimus=${__VK_LAYER_NV_optimus:-NVIDIA_only}
fi

if [ "$use_process_japanese_locale" -eq 1 ]; then
    # The original sets these to [string][char]N - a single UTF-16 code unit
    # with ordinal N. Wine re-encodes a child's Unix (UTF-8) environment into
    # UTF-16 for the Windows side, so writing the UTF-8 encoding of the same
    # code point here reconstructs the identical UTF-16 value on that side.
    export LRCodePage=$(printf 'Τ')   # 932
    export LRLCID=$(printf 'Б')       # 1041
    export LRBIAS=$(printf 'Ȝ')       # 540
    export LRHookLCID=$(printf '')   # 1
    unset LRHookIME
fi

launch_arguments=(-d)
# Works around Wine's ntdll not implementing NtQueryInformationByName, which
# makes zh/fgozh.dll (and potentially other hook DLLs) abort DllMain under
# Wine. See shims/ntquery_shim.c for the full explanation. Must load first.
ntquery_shim_path="$SCRIPT_DIR/shims/ntquery_shim.dll"
[ -f "$ntquery_shim_path" ] && launch_arguments+=(-k "$ntquery_shim_path")
# ago.exe statically imports USER32.dll's SetWindowFeedbackSetting, which
# Wine doesn't implement - Wine's loader binds that import to its own
# "unimplemented, calling this aborts" trampoline, so the game hard-aborts
# the moment it calls it. See shims/feedback_shim.c. Timing doesn't matter
# relative to the other -k DLLs (it patches ago.exe's own import table, not
# something another injected DLL depends on), as long as it runs before the
# game actually calls the function - any position in this chain is early
# enough.
feedback_shim_path="$SCRIPT_DIR/shims/feedback_shim.dll"
[ -f "$feedback_shim_path" ] && launch_arguments+=(-k "$feedback_shim_path")
[ "$use_process_japanese_locale" -eq 1 ] && launch_arguments+=(-k "$locale_hook_path")
[ -f "$gl_compat_path" ] && launch_arguments+=(-k "$gl_compat_path")
launch_arguments+=(-k "$hook_path")
use_chinese=0
[ "$opt_chinese" -eq 1 ] && use_chinese=1
[ "$CFG_CHINESEENABLED" = "1" ] && use_chinese=1
easter_settings="$game_root/BGM/settings.ini"
use_master_easter=0
[ -f "$easter_settings" ] && grep -Eq '^\s*enabled\s*=\s*1\s*$' "$easter_settings" && use_master_easter=1
if [ "$use_chinese" -eq 1 ] || [ "$use_master_easter" -eq 1 ]; then
    [ -f "$chinese_hook_path" ] || fgo_die "Chinese resource hook is missing: $chinese_hook_path" 1
    launch_arguments+=(-k "$chinese_hook_path")
    [ "$use_chinese" -eq 1 ] && fgo_log "[zh] Chinese resources enabled: $game_root/zh (missing resources use original files)."
    [ "$use_master_easter" -eq 1 ] && fgo_log "[easter] Master portraits enabled: $game_root/EasterEgg"
fi
[ "$use_audio_hook" -eq 1 ] && launch_arguments+=(-k "$audio_hook_path")
launch_arguments+=("$ago_path" "$native_render_argument")
[ "$effective_cabinet_mode" != saved ] && launch_arguments+=(-sm "$effective_cabinet_mode")
[ "$effective_windowed" -eq 1 ] && launch_arguments+=(-w)
[ "$use_wasapi_shared" -eq 1 ] && launch_arguments+=(--wasapi-shared)

deck_channel=FGODeck_$(printf '%s' "${game_root^^}" | sha256sum | tr -d ' -' | tr 'a-f' 'A-F')
export FGO_DECK_CHANNEL="$deck_channel"
export FGO_ZH_ENABLED=$use_chinese
if [ "$effective_display_mode" = borderless ]; then
    export __COMPAT_LAYER="${__COMPAT_LAYER:+$__COMPAT_LAYER }DISABLEDXMAXIMIZEDWINDOWEDMODE"
    export FGO_BORDERLESS_COMPOSED=1
fi
unset FGO_GL_PASSTHROUGH
[ -f "$game_root/fgo-gl-diagnostics.enabled" ] && export FGO_GL_DIAGNOSTICS=1
unset FGO_SKY_UPLOAD_CAPTURE
export FGO_FULL_SURFACE_FBO=1

clamp_num() { # value min max default
    local v=$1 min=$2 max=$3 default=$4
    if [[ "$v" =~ ^-?[0-9]+([.][0-9]+)?$ ]] && awk -v v="$v" -v mn="$min" -v mx="$max" 'BEGIN{exit !(v>=mn && v<=mx)}' </dev/null; then
        echo "$v"
    else
        echo "$default"
    fi
}
in_set() { for x in "${@:2}"; do [ "$x" = "$1" ] && return 0; done; return 1; }

smaa=$GFX_SMAA; in_set "$smaa" 0 1 2 || smaa=0
anisotropy=$GFX_ANISOTROPY; in_set "$anisotropy" 1 2 4 8 16 || anisotropy=16
hide_ui_key=$GFX_HIDEUIKEY
[[ "$hide_ui_key" =~ ^[0-9]+$ ]] && [ "$hide_ui_key" -ge 8 ] && [ "$hide_ui_key" -le 254 ] || hide_ui_key=121
render_scale=${FGO_RENDER_SCALE:-$GFX_RENDERSCALE}
in_set "$render_scale" 100 125 150 200 || render_scale=100
shadow_resolution=$GFX_SHADOWRESOLUTION
in_set "$shadow_resolution" 1024 2048 4096 || shadow_resolution=0

export FGO_SMAA=$smaa
export FGO_RENDER_SCALE=$render_scale
export FGO_SHADOW_RESOLUTION=$shadow_resolution
export FGO_HIDE_TARGET_LINES=$([ "$GFX_HIDETARGETLINES" = 1 ] && echo 1 || echo 0)
export FGO_DAMAGE_NUMBER_SCALE=$(clamp_num "$GFX_DAMAGENUMBERSCALE" 0 200 100)
export FGO_DAMAGE_TEXTURE_SCALE=$(clamp_num "$GFX_DAMAGETEXTURESCALE" 0 200 100)
export FGO_DAMAGE_NUMBER_OPACITY=$(clamp_num "$GFX_DAMAGENUMBEROPACITY" 0 100 100)
export FGO_DAMAGE_TEXTURE_OPACITY=$(clamp_num "$GFX_DAMAGETEXTUREOPACITY" 0 100 100)

default_photo_keys=(120 87 83 65 68 81 69 37 39 38 40 90 67 82)
if [ "${#GFX_PHOTO_KEYS[@]}" -eq 14 ]; then
    photo_keys=()
    for i in "${!default_photo_keys[@]}"; do
        k=${GFX_PHOTO_KEYS[$i]}
        if [[ "$k" =~ ^[0-9]+$ ]] && [ "$k" -ge 8 ] && [ "$k" -le 254 ]; then
            photo_keys+=("$k")
        else
            photo_keys+=("${default_photo_keys[$i]}")
        fi
    done
else
    photo_keys=("${default_photo_keys[@]}")
fi
export FGO_PHOTO_KEY="${photo_keys[0]}"
export FGO_PHOTO_KEYS="$(IFS=,; echo "${photo_keys[*]:1}")"
export FGO_ANISOTROPY=$anisotropy
export FGO_MOTION_BLUR=$([ "$GFX_MOTIONBLUR" = 1 ] && echo 1 || echo 0)
export FGO_DEPTH_OF_FIELD=$([ "$GFX_DEPTHOFFIELD" = 0 ] && echo 0 || echo 1)
export FGO_BLOOM=$([ "$GFX_BLOOM" = 0 ] && echo 0 || echo 1)
export FGO_HIDE_UI=$([ "$GFX_HIDEUI" = 1 ] && echo 1 || echo 0)
export FGO_DISABLE_CAMERA_SHAKE=$([ "$GFX_DISABLECAMERASHAKE" = 1 ] && echo 1 || echo 0)
export FGO_HIDE_CABINET_HUD=$([ "$GFX_HIDECABINETHUD" = 1 ] && echo 1 || echo 0)
export FGO_HIDE_UI_KEY=$hide_ui_key
unset FGO_DISABLE_FRAME_PACING
export FGO_TEXTURE_QUALITY=0
unset FGO_SKY_DIAGNOSTICS FGO_SKY_RESTART_FIX FGO_SKY_DEPTH_EQUAL_FIX FGO_SKY_DOME_EXTEND_PERCENT FGO_SKY_CULL_FIX FGO_SKY_BACKGROUND_FIX

fgo_log "Virtual LAN: $net_cabinet (local bridge=$([ "$net_local" -eq 1 ] && echo True || echo False))"
fgo_log "Server     : $server_host"
fgo_log "Version    : $effective_game_version"
fgo_log "Input      : $effective_input_mode"
fgo_log "Display    : $effective_display_mode ${effective_resolution_width}x${effective_resolution_height}"
fgo_log "Renderer   : $native_render_argument native; UI/touch safe area 1920x1080"
fgo_log "Frame rate : $effective_target_fps FPS (engine-normalized)"
fgo_log "Launch log : $launch_log_path"

if [ "$opt_check_only" -eq 1 ]; then
    fgo_log "FGO startup checks passed; runtime configuration prepared."
    exit 0
fi

# Best-effort cleanup of leftover processes from a previous run of this
# install. Matched as a plain glob (not a regex) against the full command
# line, since game_root can contain regex metacharacters pkill -f would
# otherwise misinterpret. After this, the pidfile written below is
# authoritative for the process we ourselves start.
for exe_name in ago.exe amdaemon.exe inject.exe; do
    while read -r leftover_pid leftover_cmd; do
        case "$leftover_cmd" in
            "$game_root"*"$exe_name"*) kill -9 "$leftover_pid" 2>/dev/null ;;
        esac
    done < <(pgrep -af "$exe_name" 2>/dev/null)
done

if [ -f "$pending_hook_path" ]; then
    backup_directory="$game_root/backup"
    mkdir -p "$backup_directory"
    stamp=$(date +%Y%m%d_%H%M%S)
    cp -f "$hook_path" "$backup_directory/fgohook-before-update-$stamp.dll"
    mv -f "$pending_hook_path" "$hook_path"
    fgo_log "Installed staged FGO compatibility hook; backup: $backup_directory/fgohook-before-update-$stamp.dll"
fi

pending_bgm_directory="$game_root/BGM/pending"
if [ -d "$pending_bgm_directory" ]; then
    bgm_backup_directory="$game_root/backup/bgm-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$bgm_backup_directory"
    for bgm_file in "$pending_bgm_directory"/*.ogg; do
        [ -e "$bgm_file" ] || continue
        bgm_destination="$game_root/BGM/$(basename "$bgm_file")"
        [ -f "$bgm_destination" ] && cp -f "$bgm_destination" "$bgm_backup_directory/"
        mv -f "$bgm_file" "$bgm_destination"
    done
fi

if [ -f "$pending_chinese_hook_path" ]; then
    chinese_backup_directory="$game_root/backup"
    mkdir -p "$chinese_backup_directory"
    [ -f "$chinese_hook_path" ] && cp -f "$chinese_hook_path" "$chinese_backup_directory/fgozh-before-update-$(date +%Y%m%d_%H%M%S).dll"
    mv -f "$pending_chinese_hook_path" "$chinese_hook_path"
    fgo_log "[zh] Installed staged Chinese hook update."
fi

launch_start=$(date +%s)
cd "$game_root" || fgo_die "Cannot enter $game_root" 1

# Optional: run the whole session inside gamescope (a nested Wayland/X11
# compositor) instead of directly on the host compositor. Sidesteps the
# host-window-manager focus interactions that can leave the game window
# withdrawn/invisible (see NOTES.md) by giving the game its own compositor
# to own start to finish, and centralizes fullscreen/resolution presentation
# in one place instead of Windows-style displayMode/monitorDevice settings.
# Opt-in via FGO_GAMESCOPE=1 in fgo.env; inner size matches whatever
# resolution is already configured (effective_resolution_width/height) - no
# separate gamescope-specific size setting to keep in sync.
launch_cmd=("${FGO_WINE:-wine}" "$inject_path" "${launch_arguments[@]}")
if [ "${FGO_GAMESCOPE:-0}" = "1" ]; then
    fgo_require_cmd gamescope
    gamescope_args=(-W "$effective_resolution_width" -H "$effective_resolution_height")
    [ "${FGO_GAMESCOPE_FULLSCREEN:-0}" = "1" ] && gamescope_args+=(-f)
    launch_cmd=(gamescope "${gamescope_args[@]}" -- "${launch_cmd[@]}")
fi

"${launch_cmd[@]}" \
    > >(tee -a "$inject_live_log_path" "$launch_log_path") \
    2> >(tee -a "$inject_live_log_path" "$launch_log_path" >&2) &
game_pid=$!
mkdir -p "$state_dir"
echo "$game_pid" > "$state_dir/game.pid"
wait "$game_pid"
game_exit_code=$?
rm -f "$state_dir/game.pid"

session_seconds=$(( $(date +%s) - launch_start ))

if [ "$game_exit_code" -ne 0 ]; then
    fgo_die "ago.exe crashed after ${session_seconds}s (exit $game_exit_code). Check the logs folder." 22
fi
if [ "$session_seconds" -lt 60 ]; then
    fgo_die "ago.exe closed after ${session_seconds}s without a crash code. Check the logs folder." 22
fi

fgo_log "FGO session ended normally."
exit 0
