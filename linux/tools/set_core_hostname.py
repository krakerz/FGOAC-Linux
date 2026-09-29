"""Rewrite Server/artemis/config/core.yaml's server.hostname line in place.

Kept as a plain 2-space-indent regex edit (matching the original
Start-FGOLocalServer.ps1 and Server/tools/fgo_server_config.py) instead of a
full YAML rewrite, so it doesn't reformat or reorder the rest of the file.

Usage: set_core_hostname.py CORE_YAML_PATH HOST ALREADY_OPEN(0|1)
Exit codes: 0 unchanged/changed (prints which to stdout),
            2 no hostname: line found and it doesn't already match,
            3 change needed but the port is already open (server busy).
"""
import re
import sys

path, host, already_open = sys.argv[1], sys.argv[2], sys.argv[3] == "1"
text = open(path, encoding="utf-8").read()
pattern = re.compile(r'(?m)^(\s{2}hostname:\s*).+$')
match = pattern.search(text)
current = match.group(0).split(":", 1)[1].strip().strip('"') if match else None

if current == host:
    print("unchanged")
    sys.exit(0)
if not match:
    print(f"Could not find a 'hostname:' line to update in {path}", file=sys.stderr)
    sys.exit(2)
if already_open:
    print("The server is still using the old address. Stop the local server, "
          "then start it again to enable the offline virtual network.", file=sys.stderr)
    sys.exit(3)

updated = pattern.sub(lambda m: m.group(1) + f'"{host}"', text, count=1)
open(path, "w", encoding="utf-8").write(updated)
print("changed")
