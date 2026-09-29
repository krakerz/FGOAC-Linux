"""Manifest-driven copy/checksum/backup core of Apply-EN-Patch.ps1, factored
out of bash for the same reason as the rest of this port: path-safety and
checksum logic is easy to get subtly wrong in shell, and this only needs the
standard library.

Usage:
  apply_patch_files.py apply INSTALL_ROOT PACKAGE_ROOT MANIFEST_PATH MARKER_PATH FORCE(0|1)
  apply_patch_files.py rollback INSTALL_ROOT MARKER_PATH

Prints one JSON object on success and exits nonzero (with an error on
stderr) on any problem, using the same exit codes as the original script.
"""
import hashlib
import json
import shutil
import sys
from datetime import datetime, timezone
from pathlib import Path

PROTECTED_PREFIXES = ("Server/state/", "Server/data/", "DEVICE/", "AMFS/", "GameData/",
                       "_en-patch-backup/", "_update-backup/")
PROTECTED_FILES = ("App/fgo-launcher.json", "App/deck.json", "App/deck.json.bak")


def die(message, code):
    print(message, file=sys.stderr)
    sys.exit(code)


def sha256_of(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def destination_path(root: Path, relative: str) -> Path:
    rel = relative.replace("\\", "/")
    if rel.startswith("/") or ":" in rel.split("/")[0] or ".." in rel.split("/"):
        die(f"The patch package lists an invalid path: {relative}", 5)
    lowered = rel.lower()
    for prefix in PROTECTED_PREFIXES:
        if lowered.startswith(prefix.lower()):
            die(f"The patch package lists a file the patch is not allowed to write: {relative}", 5)
    for protected in PROTECTED_FILES:
        if lowered == protected.lower():
            die(f"The patch package lists a file the patch is not allowed to write: {relative}", 5)
    full = (root / rel).resolve()
    if root not in full.parents and full != root:
        die(f"The patch package lists a path outside the game folder: {relative}", 5)
    return full


def do_rollback(install_root: Path, marker_path: Path):
    backup_root = install_root / "_en-patch-backup"
    if not backup_root.is_dir():
        die(f"There is no patch backup to restore in {backup_root}.", 7)
    backups = sorted(p for p in backup_root.iterdir() if p.is_dir())
    if not backups:
        die(f"There is no patch backup to restore in {backup_root}.", 7)
    backup = backups[-1]
    record_path = backup / "en-patch-restore.json"
    if not record_path.is_file():
        die(f"The backup in {backup} has no en-patch-restore.json, so it cannot be rolled back automatically.", 7)
    record = json.loads(record_path.read_text(encoding="utf-8"))

    restored = 0
    for rel in record.get("replaced", []):
        saved = backup / rel
        if saved.is_file():
            dest = install_root / rel
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(saved, dest)
            restored += 1

    removed = 0
    for rel in record.get("added", []):
        added = install_root / rel
        if added.is_file():
            added.unlink()
            removed += 1

    saved_marker = backup / "App/zh/en-patch.json"
    if saved_marker.is_file():
        marker_path.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(saved_marker, marker_path)
    elif marker_path.exists():
        marker_path.unlink()

    print(json.dumps({"restored": restored, "removed": removed,
                       "message": f"Rollback finished: {restored} files restored, {removed} files removed."}))


def main():
    if sys.argv[1] == "rollback":
        do_rollback(Path(sys.argv[2]).resolve(), Path(sys.argv[3]))
        return

    install_root = Path(sys.argv[2]).resolve()
    package_root = Path(sys.argv[3]).resolve()
    manifest_path = Path(sys.argv[4])
    marker_path = Path(sys.argv[5])
    force = sys.argv[6] == "1"

    # package_root/payload is the normal packaged-release layout (manifest.json
    # + payload/ as siblings). If there's no payload/ there but package_root
    # itself directly holds App/ and/or Server/, the caller pointed straight
    # at a payload folder (e.g. a plain checkout of the patch source, with no
    # packaged release/manifest at all) - treat it as the payload root itself.
    if (package_root / "payload").is_dir():
        payload_root = package_root / "payload"
    elif (package_root / "App").is_dir() or (package_root / "Server").is_dir():
        payload_root = package_root
    else:
        payload_root = package_root / "payload"

    if manifest_path.is_file():
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        version = str(manifest["version"])
        manifest_hash = str(manifest["manifestHash"])
        entries = manifest.get("files") or {}
        if not entries:
            die("The patch package is incomplete: manifest.json lists no files.", 5)
    else:
        # No manifest.json - build the file list straight from payload/ and
        # use each source file's own hash as the "expected" one, so the same
        # already-installed/backup/rollback pipeline below still works
        # without an independently-published checksum to verify against.
        entries = {}
        if not payload_root.is_dir():
            die(f"The patch package is incomplete: neither manifest.json nor a payload/ folder was found under {package_root}.", 5)
        for path in sorted(payload_root.rglob("*")):
            if path.is_file():
                entries[str(path.relative_to(payload_root)).replace("\\", "/")] = sha256_of(path)
        if not entries:
            die(f"The patch package is incomplete: payload/ at {payload_root} has no files.", 5)
        version = "unversioned"
        manifest_hash = hashlib.sha256("".join(f"{k}={v}" for k, v in sorted(entries.items())).encode()).hexdigest()

    if not force and marker_path.exists():
        try:
            marker = json.loads(marker_path.read_text(encoding="utf-8"))
            if str(marker.get("version")) == version and str(marker.get("manifestHash")) == manifest_hash:
                replaced = None
                for rel in entries:
                    if rel.replace("\\", "/").lower().startswith("app/zh/rom/") or rel == "FGOAC scooby.exe":
                        continue
                    installed = destination_path(install_root, rel)
                    if not installed.exists() or sha256_of(installed) != str(entries[rel]):
                        replaced = rel
                        break
                if replaced is None:
                    print(json.dumps({"version": version, "copied": 0, "backup": None,
                                       "message": f"The English patch version {version} is already installed in {install_root}. Nothing was changed."}))
                    return
        except Exception:
            pass

    plan = []
    for raw_rel, expected in entries.items():
        # Manifest keys are Windows-style ("App\\FGO_Launcher.ps1"); normalize
        # once here so source lookup, destination, and the backup/restore
        # records below all agree on the same forward-slash path.
        rel = raw_rel.replace("\\", "/")
        destination = destination_path(install_root, rel)
        source = payload_root / rel
        if not source.is_file():
            source = package_root / rel
        if not source.is_file():
            die(f"The patch package is incomplete: {rel} is missing. Unzip the whole package again.", 5)
        plan.append((rel, source, destination, str(expected)))

    to_copy = [item for item in plan if not item[2].exists() or sha256_of(item[2]) != item[3]]

    if not to_copy:
        print(json.dumps({"version": version, "copied": 0, "backup": None,
                           "message": "Every file was already in place, so only the marker needed writing."}))
        return

    stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    backup_dir = install_root / "_en-patch-backup" / stamp
    backup_dir.mkdir(parents=True, exist_ok=True)
    replaced_rel, added_rel = [], []
    for rel, _source, destination, _expected in to_copy:
        if destination.exists():
            backup_dest = backup_dir / rel
            backup_dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(destination, backup_dest)
            replaced_rel.append(rel)
        else:
            added_rel.append(rel)
    if marker_path.exists():
        saved_marker = backup_dir / "App/zh/en-patch.json"
        saved_marker.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(marker_path, saved_marker)
    (backup_dir / "en-patch-restore.json").write_text(json.dumps({
        "version": version,
        "savedUtc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "replaced": replaced_rel,
        "added": added_rel,
    }, indent=2), encoding="utf-8")

    for rel, source, destination, _expected in to_copy:
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, destination)

    bad = [rel for rel, _s, destination, expected in to_copy if sha256_of(destination) != expected]
    if bad:
        die("These files did not match their checksum after copying, so the patch is not complete:\n"
            + "\n".join(f"  {rel}" for rel in bad)
            + f"\nRun the patch again; if it keeps failing, check available disk space. The replaced files are in {backup_dir}, and --rollback puts them back.", 6)

    marker_path.parent.mkdir(parents=True, exist_ok=True)
    marker_path.write_text(json.dumps({
        "version": version,
        "appliedUtc": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "manifestHash": manifest_hash,
    }, indent=2), encoding="utf-8")

    print(json.dumps({"version": version, "copied": len(to_copy), "backup": str(backup_dir),
                       "message": f"The English patch version {version} is installed in {install_root}."}))


if __name__ == "__main__":
    main()
