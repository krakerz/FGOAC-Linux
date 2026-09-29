"""Write a copy of fgohook.dll with its hard 60 FPS clamp removed.

fgohook reads FGO_TARGET_FPS (accepted 30-360). At 0x180013b09 a `jbe` skips
the clamp only when the value is <= 60; above 60 it logs "experimental engine
hooks suspended after UI/input regression", forces 60, and so never reaches
its own high-FPS installer (0x180014540, called later when fps > 60). Turning
that `jbe` into an unconditional `jmp` (same target) is the whole patch.

Only the exact DLL this was analysed against is patched; anything else is
refused rather than guessed at. The original file is never modified.

usage: patch_fgohook_highfps.py SOURCE_DLL OUTPUT_DLL
"""
import hashlib
import sys
from pathlib import Path

KNOWN_SOURCE_SHA256 = "1111e2c086ea5ab9eaa24ad2c3280b6f487fededecfc1b0a455a8e808939af20"
PATCH_OFFSET = 0x12F09  # file offset of VA 0x180013b09 (.text VMA 0x180001000 -> raw 0x400)
ORIGINAL_BYTES = bytes([0x76, 0x65])  # jbe short 0x180013b70
PATCHED_BYTES = bytes([0xEB, 0x65])   # jmp short 0x180013b70


def main():
    if len(sys.argv) != 3:
        print(__doc__.strip().splitlines()[-1], file=sys.stderr)
        return 2
    source, output = Path(sys.argv[1]), Path(sys.argv[2])
    data = source.read_bytes()
    digest = hashlib.sha256(data).hexdigest()
    if digest != KNOWN_SOURCE_SHA256:
        print(f"refusing to patch {source}: sha256 {digest} is not the analysed build "
              f"{KNOWN_SOURCE_SHA256}", file=sys.stderr)
        return 1
    found = data[PATCH_OFFSET:PATCH_OFFSET + len(ORIGINAL_BYTES)]
    if found != ORIGINAL_BYTES:
        print(f"refusing to patch {source}: expected {ORIGINAL_BYTES.hex()} at "
              f"0x{PATCH_OFFSET:x}, found {found.hex()}", file=sys.stderr)
        return 1
    patched = data[:PATCH_OFFSET] + PATCHED_BYTES + data[PATCH_OFFSET + len(PATCHED_BYTES):]
    if output.exists() and output.read_bytes() == patched:
        return 0
    temporary = output.with_name(output.name + ".tmp")
    temporary.write_bytes(patched)
    temporary.replace(output)
    print(f"wrote high-FPS hook copy {output}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
