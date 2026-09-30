"""Check / initialise the ARTEMiS MariaDB database for the GUI's Server tab.

Connection settings come from Server/artemis/config/core.yaml's database:
section; any --host/--user/--name/--port given (and FGO_DB_PASSWORD in the
environment) override it, so unsaved GUI fields can be tested before Save.

  status  -> one JSON line: {"ok": bool, "error": str, "initialized": bool, "tables": int}
             "initialized" = the aime_user table exists (ARTEMiS's core user table).
  init    -> imports --sql (a mariadb-dump, e.g. linux/backups/*.sql) into the
             database, creating the database first if it doesn't exist.
             Refuses when aime_user already exists, so it can't overwrite
             an existing account.

usage: fgo_db.py status|init --core CORE_YAML [--sql FILE] [--host H] [--user U] [--name N] [--port P]
"""
import argparse
import json
import os
import sys

import pymysql
import yaml

MARKER_TABLE = "aime_user"


def settings(args):
    with open(args.core, encoding="utf-8") as source:
        database = (yaml.safe_load(source) or {}).get("database") or {}
    return {
        "host": args.host or str(database.get("host", "127.0.0.1")),
        "user": args.user or str(database.get("username", "")),
        "password": os.environ.get("FGO_DB_PASSWORD") or str(database.get("password", "")),
        "name": args.name or str(database.get("name", "")),
        "port": int(args.port or database.get("port", 3306)),
    }


def connect(cfg, database=True, **extra):
    return pymysql.connect(host=cfg["host"], port=cfg["port"], user=cfg["user"], password=cfg["password"],
                           database=cfg["name"] if database else None, connect_timeout=5,
                           charset="utf8mb4", **extra)


def table_count(connection, name):
    with connection.cursor() as cursor:
        cursor.execute("SELECT COUNT(*), SUM(TABLE_NAME = %s) FROM information_schema.TABLES "
                       "WHERE TABLE_SCHEMA = %s", (MARKER_TABLE, name))
        total, marker = cursor.fetchone()
    return int(total or 0), bool(marker)


def status(cfg):
    try:
        connection = connect(cfg)
    except pymysql.err.OperationalError as error:
        code = error.args[0] if error.args else 0
        if code == 1049:  # unknown database: the server answered, init can create it
            return {"ok": True, "error": f"Database '{cfg['name']}' does not exist yet.",
                    "initialized": False, "tables": 0}
        return {"ok": False, "error": f"{cfg['host']}:{cfg['port']} - {error.args[-1] if error.args else error}",
                "initialized": False, "tables": 0}
    except Exception as error:  # noqa: BLE001 - reported to the GUI as text
        return {"ok": False, "error": f"{cfg['host']}:{cfg['port']} - {error}", "initialized": False, "tables": 0}
    with connection:
        tables, initialized = table_count(connection, cfg["name"])
    return {"ok": True, "error": "", "initialized": initialized, "tables": tables}


def init(cfg, sql_path):
    state = status(cfg)
    if not state["ok"]:
        raise SystemExit(f"Cannot connect: {state['error']}")
    if state["initialized"]:
        raise SystemExit(f"'{cfg['name']}' already has the {MARKER_TABLE} table - refusing to overwrite it.")
    with open(sql_path, encoding="utf-8") as source:
        script = source.read()
    with connect(cfg, database=False) as connection:
        with connection.cursor() as cursor:
            name = cfg["name"].replace("`", "``")
            cursor.execute(f"CREATE DATABASE IF NOT EXISTS `{name}` CHARACTER SET utf8mb4")
    with connect(cfg, client_flag=pymysql.constants.CLIENT.MULTI_STATEMENTS) as connection:
        with connection.cursor() as cursor:
            cursor.execute(script)
            while cursor.nextset():
                pass
        connection.commit()
        tables, initialized = table_count(connection, cfg["name"])
    if not initialized:
        raise SystemExit(f"Imported {sql_path}, but {MARKER_TABLE} is still missing - is it an ARTEMiS dump?")
    print(f"Imported {os.path.basename(sql_path)} into '{cfg['name']}': {tables} tables.")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("action", choices=("status", "init"))
    parser.add_argument("--core", required=True)
    parser.add_argument("--sql")
    for option in ("host", "user", "name", "port"):
        parser.add_argument(f"--{option}")
    args = parser.parse_args()
    cfg = settings(args)
    if args.action == "status":
        print(json.dumps(status(cfg)))
        return 0
    if not args.sql:
        parser.error("init needs --sql")
    init(cfg, args.sql)
    return 0


if __name__ == "__main__":
    sys.exit(main())
