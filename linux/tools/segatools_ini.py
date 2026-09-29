"""Port of FGO_Launcher.ps1's Set-IniValue: replace/append one key=value in
one [section] of an ini file, in place, preserving everything else.

Usage: segatools_ini.py PATH SECTION KEY VALUE
"""
import re
import sys


def get_ini_value(text, section, key, default=None):
    """Reads one key=value from one [section], mirroring set_ini_value's own
    section/key matching exactly so a value just written by set_ini_value is
    always read back correctly. Returns default if the section or key isn't
    present."""
    header_pattern = re.compile(r'(?m)^\[' + re.escape(section) + r'\]\s*$')
    header = header_pattern.search(text)
    if not header:
        return default

    section_start = header.end()
    next_header = re.compile(r'(?m)^\[[^\]]+\]\s*$').search(text, section_start)
    section_end = next_header.start() if next_header else len(text)
    body = text[section_start:section_end]

    key_match = re.search(r'(?m)^\s*' + re.escape(key) + r'\s*=(.*)$', body)
    return key_match.group(1).strip() if key_match else default


def set_ini_value(text, section, key, value):
    header_pattern = re.compile(r'(?m)^\[' + re.escape(section) + r'\]\s*$')
    header = header_pattern.search(text)
    if not header:
        return text.rstrip('\n') + f'\r\n\r\n[{section}]\r\n{key}={value}\r\n'

    section_start = header.end()
    next_header = re.compile(r'(?m)^\[[^\]]+\]\s*$').search(text, section_start)
    section_end = next_header.start() if next_header else len(text)
    body = text[section_start:section_end]

    key_pattern = re.compile(r'(?m)^(\s*' + re.escape(key) + r'\s*=).*$')
    key_match = key_pattern.search(body)
    if key_match:
        body = body[:key_match.start()] + key_match.group(1) + str(value) + body[key_match.end():]
    else:
        body = f'\r\n{key}={value}' + body

    return text[:section_start] + body + text[section_end:]


def main():
    path, section, key, value = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
    text = open(path, encoding="utf-8").read()
    open(path, "w", encoding="utf-8").write(set_ini_value(text, section, key, value))


if __name__ == "__main__":
    main()
