"""Read/write linux/fgo.env values in place, preserving comments and
untouched lines - the same "replace existing, or the commented-out
placeholder, or append" logic setup.sh's own set_env_value shell function
uses, just usable directly from Python instead of shelling out to sed once
per key.
"""
import re
from pathlib import Path


def env_file_path():
    return Path(__file__).resolve().parent.parent / "fgo.env"


def read_env_file(path=None):
    path = path or env_file_path()
    if not path.exists():
        example = path.with_name("fgo.env.example")
        return example.read_text(encoding="utf-8") if example.exists() else ""
    return path.read_text(encoding="utf-8")


def get_env_value(text, key, default=""):
    match = re.search(r'(?m)^' + re.escape(key) + r'="(.*)"\s*$', text)
    return match.group(1) if match else default


def set_env_value(text, key, value):
    """Mirrors setup.sh's set_env_value: replace an active KEY="...", else an
    inactive #KEY="...", else append a new line."""
    escaped = value.replace("\\", r"\\").replace('"', r"\"")
    line = f'{key}="{escaped}"'
    active = re.compile(r'(?m)^' + re.escape(key) + r'=.*$')
    if active.search(text):
        return active.sub(line, text, count=1)
    inactive = re.compile(r'(?m)^#' + re.escape(key) + r'=.*$')
    if inactive.search(text):
        return inactive.sub(line, text, count=1)
    sep = "" if text.endswith("\n") or not text else "\n"
    return text + sep + line + "\n"


def set_env_values(values, path=None):
    """values: dict of {key: value}. Skips (key, None) - use None to mean
    'leave unset/unchanged', since not every Setup field is always filled
    in."""
    path = path or env_file_path()
    text = read_env_file(path)
    for key, value in values.items():
        if value is None:
            continue
        text = set_env_value(text, key, value)
    path.write_text(text, encoding="utf-8")
