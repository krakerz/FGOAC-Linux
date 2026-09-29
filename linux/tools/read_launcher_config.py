"""Read App/fgo-launcher.json (+ validate config.json) and print shell
assignments for fgo-launcher.sh to `eval`. Centralizing this in one process
avoids dozens of separate python3 subprocess calls per field.

Usage: read_launcher_config.py LAUNCHER_JSON_PATH CONFIG_JSON_PATH
"""
import json
import shlex
import sys


def sh(name, value):
    if isinstance(value, bool):
        value = "1" if value else "0"
    elif value is None:
        value = ""
    print(f"{name}={shlex.quote(str(value))}")


def main():
    launcher_path, config_path = sys.argv[1], sys.argv[2]
    launcher = json.loads(open(launcher_path, encoding="utf-8").read())
    # config.json isn't otherwise used by the launcher - this only checks it parses,
    # matching the original's required-files validation.
    json.loads(open(config_path, encoding="utf-8").read())

    scalar_fields = [
        ("serverHost", "auto"), ("autoStartLocalServer", True),
        ("localServerLauncher", ""), ("inputMode", "xinput"),
        ("cabinetMode", "saved"), ("gameVersion", "11.00"),
        ("displayMode", ""), ("windowed", False), ("monitorDevice", ""),
        ("resolutionWidth", 0), ("resolutionHeight", 0), ("targetFps", 60),
        ("audioHook", False), ("processJapaneseLocale", False),
        ("wasapiShared", False), ("preferHighPerformanceGpu", True),
        ("diagnostics", False), ("cryptoDiagnostics", False),
        ("protocolDiagnostics", None), ("chineseEnabled", False),
    ]
    for key, default in scalar_fields:
        value = launcher.get(key)
        sh("CFG_" + key.upper(), default if value is None else value)

    ports = launcher.get("serverPorts") or {}
    sh("CFG_SERVERPORTS_HTTP", ports.get("http", 0))
    sh("CFG_SERVERPORTS_BILLING", ports.get("billing", 0))
    sh("CFG_SERVERPORTS_AIME", ports.get("aime", 0))
    print("CFG_REQUIREDPORTS=(" + " ".join(shlex.quote(str(p)) for p in launcher.get("requiredPorts") or []) + ")")

    graphics = launcher.get("graphics") or {}
    graphics_fields = [
        ("smaa", 0), ("anisotropy", 16), ("hideUiKey", 121),
        ("renderScale", 100), ("shadowResolution", 0),
        ("hideTargetLines", False), ("damageNumberScale", 100),
        ("damageTextureScale", 100), ("damageNumberOpacity", 100),
        ("damageTextureOpacity", 100), ("motionBlur", False),
        ("depthOfField", True), ("bloom", True), ("hideUi", False),
        ("disableCameraShake", False), ("hideCabinetHud", False),
    ]
    for key, default in graphics_fields:
        value = graphics.get(key)
        sh("GFX_" + key.upper(), default if value is None else value)

    photo_keys = (graphics.get("photo") or {}).get("keys")
    if isinstance(photo_keys, list) and len(photo_keys) == 14:
        print("GFX_PHOTO_KEYS=(" + " ".join(shlex.quote(str(k)) for k in photo_keys) + ")")
    else:
        print("GFX_PHOTO_KEYS=()")


if __name__ == "__main__":
    main()
