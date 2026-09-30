"""Allow (or stop allowing) TLS 1.0 on ARTEMiS's billing port.

index.py's launch_billing() builds a TLS 1.0-only context (ssl_version=3),
which is what amdaemon's ALL.Net accounting report speaks. Python 3.10+
creates every SSLContext at OpenSSL security level 2, where OpenSSL 3 refuses
TLS 1.0, so every billing handshake is reset and the report can never be
delivered. A boot shortly before the daily report time (see
set_accounting_report_time.py) then hangs at "ALL.Net : WAIT (A, BUSY)".
Appending @SECLEVEL=0 to the billing cipher string lets the handshake through.

Idempotent in both directions; refuses a file that has neither the original
nor the patched line.

usage: patch_billing_tls.py apply|revert ARTEMIS_INDEX_PY
"""
import sys
from pathlib import Path

ORIGINAL = '        ssl_ciphers="DEFAULT:!aNULL:!eNULL:!MD5:!3DES:!DES:!RC4:!IDEA:!SEED:!aDSS:!SRP:!PSK",'
PATCHED = '        ssl_ciphers="DEFAULT:!aNULL:!eNULL:!MD5:!3DES:!DES:!RC4:!IDEA:!SEED:!aDSS:!SRP:!PSK:@SECLEVEL=0",'


def main():
    if len(sys.argv) != 3 or sys.argv[1] not in ("apply", "revert"):
        print(__doc__.strip().splitlines()[-1], file=sys.stderr)
        return 2
    mode, target = sys.argv[1], Path(sys.argv[2])
    old, new = (ORIGINAL, PATCHED) if mode == "apply" else (PATCHED, ORIGINAL)
    # newline="" keeps the shipped CRLF line endings byte-for-byte.
    with open(target, encoding="utf-8", newline="") as source:
        text = source.read()
    if new in text and old not in text:
        return 0
    if text.count(old) != 1:
        print(f"refusing to {mode} {target}: the billing ssl_ciphers line is not the expected one",
              file=sys.stderr)
        return 1
    updated = text.replace(old, new, 1)
    try:
        compile(updated, str(target), "exec")
    except SyntaxError as error:
        print(f"refusing to {mode} {target}: result does not compile: {error}", file=sys.stderr)
        return 1
    temporary = target.with_name(target.name + ".tmp")
    with open(temporary, "w", encoding="utf-8", newline="") as output:
        output.write(updated)
    temporary.replace(target)
    print(f"billing TLS 1.0 {'allowed' if mode == 'apply' else 'back to stock'} in {target}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
