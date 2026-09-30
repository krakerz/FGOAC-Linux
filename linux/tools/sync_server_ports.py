"""Make the game-side port settings match the server's core.yaml.

core.yaml is what ARTEMiS actually listens on. App/fgo-launcher.json
(serverPorts, requiredPorts - read by fgo-launcher.sh) and App/segatools.ini
([dns] startupPort/billingPort/aimedbPort - where the game connects) are
normally written together with it by fgo_server_config.py apply, but anything
that writes back an older copy of either file (e.g. an editor, or a settings
tab holding a copy from before the ports changed) leaves the launcher waiting
on a port nothing listens on: "not reachable on required port(s): 777".

Only the two game-side files are touched, and only when they differ; unlike
fgo_server_config.py apply this works while the server is running.

usage: sync_server_ports.py INSTALL_ROOT
"""
import json
import re
import sys
from pathlib import Path

import yaml


def set_ini(text, section, key, value):
    """Same splice as fgo_server_config.py's set_ini: keeps every other line."""
    pattern = re.compile(r"(?ms)(^\[" + re.escape(section) + r"\][^\n]*\n)(.*?)(?=^\[|\Z)")
    match = pattern.search(text)
    if not match:
        return text.rstrip() + f"\n\n[{section}]\n{key}={value}\n"
    body = match[2]
    entry = re.compile(r"(?m)^" + re.escape(key) + r"\s*=.*$")
    body = entry.sub(f"{key}={value}", body) if entry.search(body) else body.rstrip() + f"\n{key}={value}\n\n"
    return text[:match.start(2)] + body + text[match.end(2):]


def main():
    if len(sys.argv) != 2:
        print(__doc__.strip().splitlines()[-1], file=sys.stderr)
        return 2
    root = Path(sys.argv[1])
    core = yaml.safe_load((root / "Server/artemis/config/core.yaml").read_text(encoding="utf-8"))
    ports = {"http": int(core["server"]["port"]), "billing": int(core["billing"]["port"]),
             "aime": int(core["aimedb"]["port"]), "database": int(core["database"]["port"])}

    fixed = []
    launcher_path = root / "App/fgo-launcher.json"
    launcher = json.loads(launcher_path.read_text(encoding="utf-8"))
    required = [ports["http"], ports["billing"], ports["aime"]]
    if launcher.get("serverPorts") != ports or launcher.get("requiredPorts") != required:
        old = (launcher.get("serverPorts") or {}).get("http")
        launcher["serverPorts"] = ports
        launcher["requiredPorts"] = required
        launcher_path.write_text(json.dumps(launcher, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        fixed.append(f"App/fgo-launcher.json (game port {old} -> {ports['http']})")

    ini_path = root / "App/segatools.ini"
    ini = ini_path.read_text(encoding="utf-8")
    updated = ini
    for setting, key in (("startupPort", "http"), ("billingPort", "billing"), ("aimedbPort", "aime")):
        updated = set_ini(updated, "dns", setting, ports[key])
    if updated != ini:
        ini_path.write_text(updated, encoding="utf-8")
        fixed.append("App/segatools.ini [dns]")

    if fixed:
        print(f"Server ports: synced {', '.join(fixed)} to core.yaml "
              f"({ports['http']}/{ports['billing']}/{ports['aime']}).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
