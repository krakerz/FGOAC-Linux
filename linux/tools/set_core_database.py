"""Sets Server/artemis/config/core.yaml's database.host/username/password/name.

fgo_server_config.py (part of the game distribution, not this repo) only
manages the four service *ports* (http/billing/aime/database) - it never
touches where the database actually lives, so a fresh/regenerated install
always reverts to the factory default (the bundled local MariaDB at
127.0.0.1), silently losing a remote MariaDB setup with no way to reapply
it short of hand-editing the YAML. This fills that one gap.

Usage: set_core_database.py CORE_YAML_PATH [HOST] [USERNAME] [PASSWORD] [NAME]
Empty/omitted arguments leave that field unchanged. Prints the resulting
database section as JSON on success.
"""
import json
import sys

import yaml


def main():
    path = sys.argv[1]
    host, username, password, name = (sys.argv[i] if len(sys.argv) > i else "" for i in range(2, 6))

    with open(path, encoding="utf-8") as f:
        core = yaml.safe_load(f)

    if host:
        core["database"]["host"] = host
    if username:
        core["database"]["username"] = username
    if password:
        core["database"]["password"] = password
    if name:
        core["database"]["name"] = name

    with open(path, "w", encoding="utf-8") as f:
        yaml.safe_dump(core, f, allow_unicode=True, sort_keys=False)

    print(json.dumps(core["database"], ensure_ascii=False))


if __name__ == "__main__":
    main()
