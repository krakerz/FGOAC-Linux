"""Set amdaemon's daily ALL.Net accounting-report time in the Wine prefix.

amdaemon keeps its ALL.Net library settings in
<prefix>/drive_c/users/<user>/temp/alib.conf (key=value lines). Its
accounting-report.start-time (HHMM, default 0700) is when the daily report is
sent; booting shortly before it can hang the startup screen at
"ALL.Net : WAIT (A, BUSY)" because this local server can't take the report
(see patch_billing_tls.py). Moving it to an hour nobody plays moves that window.

The file is created by amdaemon on its first boot; if it doesn't exist yet
this does nothing (the next launch applies it).

usage: set_accounting_report_time.py WINEPREFIX HHMM
"""
import re
import sys
from pathlib import Path

KEY = "accounting-report.start-time"


def find_alib_conf(prefix):
    users = Path(prefix) / "drive_c" / "users"
    for path in sorted(users.glob("*/*/alib.conf")):
        if path.parent.name.lower() == "temp":
            return path
    return None


def main():
    if len(sys.argv) != 3 or not re.fullmatch(r"([01][0-9]|2[0-3])[0-5][0-9]", sys.argv[2]):
        print(__doc__.strip().splitlines()[-1], file=sys.stderr)
        return 2
    prefix, value = sys.argv[1], sys.argv[2]
    path = find_alib_conf(prefix)
    if path is None:
        return 0
    # amdaemon writes CRLF; newline="" keeps the file's own line endings.
    with open(path, encoding="utf-8", errors="replace", newline="") as source:
        text = source.read()
    eol = "\r\n" if "\r\n" in text or not text else "\n"
    line = f"{KEY}={value}"
    pattern = re.compile(r"(?m)^" + re.escape(KEY) + r"=[^\r\n]*")
    if pattern.search(text):
        updated = pattern.sub(line, text, count=1)
    else:
        updated = text + ("" if text.endswith("\n") or not text else eol) + line + eol
    if updated != text:
        with open(path, "w", encoding="utf-8", newline="") as output:
            output.write(updated)
        print(f"ALL.Net accounting report time set to {value[:2]}:{value[2:]} in {path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
