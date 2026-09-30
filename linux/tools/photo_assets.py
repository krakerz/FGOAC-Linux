"""Readers for the game's photo-mode assets (App/rom/rob/*.farc), ported from
scooby's FGOLocalPlatform.PhotoAssets so the Linux photo panel can list the
same expressions and body motions. Python 3.14+ (stdlib zstd)."""
import gzip
import json
import re
import struct
from pathlib import Path

try:
    from compression import zstd
except ImportError:  # older Python: zstd-compressed entries just can't be read
    zstd = None

ZSTD_MAGIC_LE = 4247762216
GZIP_MAGIC_LE = 134777631
TOKEN_RE = re.compile(r"(?:SVTGO|SVT|EMI|NPC|CDE|CD)_[0-9]{4}", re.IGNORECASE)


class FarcError(Exception):
    pass


class FarcEntry:
    __slots__ = ("name", "offset", "compressed_size", "uncompressed_size", "flags")

    def __init__(self, name, offset, compressed_size, uncompressed_size, flags):
        self.name = name
        self.offset = offset
        self.compressed_size = compressed_size
        self.uncompressed_size = uncompressed_size
        self.flags = flags


class FarcArchive:
    def __init__(self, path):
        self.path = Path(path)
        with open(self.path, "rb") as stream:
            self._read_directory(stream)

    def _read_directory(self, stream):
        magic = stream.read(4)
        if magic not in (b"FARc", b"FARC"):
            raise FarcError(f"not a FARC file: {magic!r}")
        header = stream.read(28)
        if len(header) != 28:
            raise FarcError("truncated FARC header")
        # header size, flags, (unused), alignment, format, count, (unused) - all big-endian
        _size, _flags, _u1, _align, _fmt, count, _u2 = struct.unpack(">7I", header)
        if count > 1_000_000:
            raise FarcError(f"FARC file count out of range: {count}")
        self.entries = []
        for _ in range(count):
            name = bytearray()
            while True:
                byte = stream.read(1)
                if not byte:
                    raise FarcError("FARC entry name runs off the end of the file")
                if byte == b"\0":
                    break
                name += byte
            offset, csize, usize, flags = struct.unpack(">4I", stream.read(16))
            self.entries.append(FarcEntry(name.decode("utf-8", "replace"), offset, csize, usize, flags))

    def matching(self, *suffixes):
        lowered = tuple(s.lower() for s in suffixes)
        return [e for e in self.entries if e.name.lower().endswith(lowered)]

    def read(self, entry):
        with open(self.path, "rb") as stream:
            stream.seek(entry.offset)
            if entry.flags == 0:
                return _read_exactly(stream, entry.compressed_size, entry.name)
            chunks = []
            if entry.flags & 0x10:
                stream.read(4)
                lengths = []
                while True:
                    (value,) = struct.unpack("<I", _read_exactly(stream, 4, entry.name))
                    if value in (GZIP_MAGIC_LE, ZSTD_MAGIC_LE):
                        break
                    if value == 0 or value > entry.compressed_size:
                        raise FarcError(f"{entry.name}: invalid compressed chunk length {value}")
                    lengths.append(value)
                    if len(lengths) > 1_000_000:
                        raise FarcError(f"{entry.name}: too many compressed chunks")
                stream.seek(-4, 1)
                chunks = [_read_exactly(stream, n, entry.name) for n in lengths]
            else:
                chunks = [_read_exactly(stream, entry.compressed_size, entry.name)]
        try:
            if entry.flags & 0x02:
                chunks = [gzip.decompress(c) for c in chunks]
            elif entry.flags & 0x20:
                if zstd is None:
                    raise FarcError("zstd-compressed entry needs Python 3.14+")
                chunks = [zstd.decompress(c) for c in chunks]
        except (OSError, EOFError, ValueError) as exc:
            raise FarcError(f"could not decompress {entry.name}: {exc}") from exc
        data = b"".join(chunks)
        if entry.uncompressed_size > 0 and len(data) != entry.uncompressed_size:
            raise FarcError(f"{entry.name} unpacked to {len(data)} bytes, expected {entry.uncompressed_size}")
        return data


def _read_exactly(stream, length, label):
    data = stream.read(length)
    if len(data) != length:
        raise FarcError(f"{label}: unexpected end of file")
    return data


def rob_directory(app_root):
    app_root = Path(app_root)
    base = app_root / "rom" if (app_root / "rom").is_dir() else app_root
    return base / "rob"


# --- Expressions (FACE_*.farc) ----------------------------------------------

def _face_duration(data):
    """Longest key time in a face-motion JSON (scooby FgoFaceMotionParser)."""
    root = json.loads(data)
    if not isinstance(root, dict):
        raise FarcError("face JSON root is not an object")
    duration = 0.0
    for keys in root.values():
        if not isinstance(keys, list):
            continue
        for key in keys:
            if isinstance(key, dict) and isinstance(key.get("time"), (int, float)) and \
                    isinstance(key.get("value"), (int, float)) and key["time"] >= 0:
                duration = max(duration, float(key["time"]))
    return duration


def list_face_motions(app_root, token):
    """[(name, source, duration_seconds)] for a model token like 'SVT_0011':
    its own FACE_<token>.farc first, then the shared FACE_CMN.farc."""
    rob = rob_directory(app_root)
    archives = []
    match = TOKEN_RE.search(Path(token).stem)
    if match:
        archives.append((rob / f"FACE_{match.group(0).upper()}.farc", "Character-specific"))
    archives.append((rob / "FACE_CMN.farc", "Shared expressions"))
    motions, seen = [], set()
    for path, source in archives:
        if not path.is_file():
            continue
        try:
            archive = FarcArchive(path)
        except (OSError, FarcError):
            continue
        for entry in archive.matching(".json"):
            file_name = entry.name.replace("\\", "/").rsplit("/", 1)[-1]
            if file_name.lower() in seen:
                continue
            try:
                duration = _face_duration(archive.read(entry))
            except (OSError, FarcError, ValueError):
                continue
            seen.add(file_name.lower())
            motions.append((Path(file_name).stem, source, duration))
    return motions


# --- Body motions (#MOT, rom/mot/mot_<token>.farc) ---------------------------
# Port of scooby FgoMotionParser / FgoMotionChannel / PhotoBodyMotionCatalog.
# Quaternions are (x, y, z, w) tuples.

MOT_VERSION = 386007831
QUAT_IDENTITY = (0.0, 0.0, 0.0, 1.0)
ROTATION_STRIDE = {14: 8, 15: 8, 16: 6, 17: 6, 18: 6, 19: 4, 20: 16, 21: 8, 22: 12, 23: 6, 24: 12}


def _is_rotation(channel_type):
    return 14 <= channel_type <= 24


def _finite(*values):
    return all(v == v and abs(v) != float("inf") for v in values)


def _check_quat(q):
    if not _finite(*q):
        raise FarcError("MOT quaternion is not finite")
    return q


def _upper_bound(values, sample):
    lo, count = 0, len(values)
    while count > 0:
        step = count // 2
        mid = lo + step
        if values[mid] <= sample:
            lo = mid + 1
            count -= step + 1
        else:
            count = step
    return lo


def _normalize_quat(q):
    length_sq = sum(c * c for c in q)
    if not _finite(length_sq) or length_sq <= 1e-12:
        return QUAT_IDENTITY
    length = length_sq ** 0.5
    return tuple(c / length for c in q)


def _shortest_lerp(a, b, t):
    if sum(x * y for x, y in zip(a, b)) < 0:
        b = tuple(-c for c in b)
    return _normalize_quat(tuple(x + (y - x) * t for x, y in zip(a, b)))


def _shortest_slerp(a, b, t):
    import math
    dot = sum(x * y for x, y in zip(a, b))
    if dot < 0:
        b = tuple(-c for c in b)
        dot = -dot
    if dot > 0.9995:
        return _shortest_lerp(a, b, t)
    theta = math.acos(max(-1.0, min(1.0, dot)))
    sin_theta = math.sin(theta)
    if abs(sin_theta) <= 1e-12:
        return a
    wa = math.sin((1 - t) * theta) / sin_theta
    wb = math.sin(t * theta) / sin_theta
    return tuple(x * wa + y * wb for x, y in zip(a, b))


def _compose_smallest_three(omitted, first, second, third, positive_omitted):
    w = max(0.0, 1.0 - first * first - second * second - third * third) ** 0.5
    if not positive_omitted:
        w = -w
    if omitted == 0:
        return _check_quat((w, first, second, third))
    if omitted == 1:
        return _check_quat((first, w, second, third))
    if omitted == 2:
        return _check_quat((first, second, w, third))
    return _check_quat((first, second, third, w))


def _quat_from_euler_xyz(x, y, z):
    """System.Numerics Quaternion.CreateFromRotationMatrix(RotX(x) * RotY(y) * RotZ(z))."""
    import math
    cx, sx, cy, sy, cz, sz = math.cos(x), math.sin(x), math.cos(y), math.sin(y), math.cos(z), math.sin(z)
    rx = [[1, 0, 0], [0, cx, sx], [0, -sx, cx]]
    ry = [[cy, 0, -sy], [0, 1, 0], [sy, 0, cy]]
    rz = [[cz, sz, 0], [-sz, cz, 0], [0, 0, 1]]
    mul = lambda a, b: [[sum(a[i][k] * b[k][j] for k in range(3)) for j in range(3)] for i in range(3)]
    m = mul(mul(rx, ry), rz)
    m11, m12, m13 = m[0]
    m21, m22, m23 = m[1]
    m31, m32, m33 = m[2]
    trace = m11 + m22 + m33
    if trace > 0:
        s = (trace + 1.0) ** 0.5
        w = s * 0.5
        s = 0.5 / s
        return ((m23 - m32) * s, (m31 - m13) * s, (m12 - m21) * s, w)
    if m11 >= m22 and m11 >= m33:
        s = (1.0 + m11 - m22 - m33) ** 0.5
        inv = 0.5 / s
        return (0.5 * s, (m12 + m21) * inv, (m13 + m31) * inv, (m23 - m32) * inv)
    if m22 > m33:
        s = (1.0 + m22 - m11 - m33) ** 0.5
        inv = 0.5 / s
        return ((m21 + m12) * inv, 0.5 * s, (m32 + m23) * inv, (m31 - m13) * inv)
    s = (1.0 + m33 - m11 - m22) ** 0.5
    inv = 0.5 / s
    return ((m31 + m13) * inv, (m32 + m23) * inv, 0.5 * s, (m12 - m21) * inv)


class MotionChannel:
    __slots__ = ("type", "key_type", "frames", "scalars", "packed")

    def __init__(self, channel_type, key_type, frames, scalars, packed):
        self.type = channel_type
        self.key_type = key_type
        self.frames = frames
        self.scalars = scalars
        self.packed = packed

    @property
    def is_rotation(self):
        return _is_rotation(self.type)

    @property
    def has_scalar_payload(self):
        return bool(self.scalars) or (self.key_type == 4 and len(self.packed) >= 12)

    def evaluate_scalar(self, frame):
        if self.key_type == 4:
            return self._evaluate_hermite(frame)
        if not self.scalars:
            return 1.0 if 6 <= self.type <= 8 else 0.0
        if len(self.scalars) == 1 or len(self.frames) <= 1:
            return self.scalars[0]
        whole = int(frame)
        if self.key_type == 2:
            index = _upper_bound(self.frames, whole)
            value = index - 1 if index > 0 and self.frames[index - 1] == whole else index
            return self.scalars[max(0, min(value, len(self.scalars) - 1))]
        index = _upper_bound(self.frames, whole)
        if index <= 0:
            return self.scalars[0]
        if index >= len(self.frames):
            return self.scalars[-1]
        prev = index - 1
        span = self.frames[index] - self.frames[prev]
        t = (frame - self.frames[prev]) / span if span > 0 else 0.0
        return self.scalars[prev] + (self.scalars[index] - self.scalars[prev]) * t

    def _hermite(self, key, component):
        return struct.unpack_from("<f", self.packed, (key * 3 + component) * 4)[0]

    def _evaluate_hermite(self, frame):
        if not self.frames or not self.packed:
            return 1.0 if 6 <= self.type <= 8 else 0.0
        if len(self.frames) == 1:
            return self._hermite(0, 0)
        index = _upper_bound(self.frames, int(frame))
        if index <= 0:
            return self._hermite(0, 0)
        if index >= len(self.frames):
            return self._hermite(len(self.frames) - 1, 0)
        prev = index - 1
        span = self.frames[index] - self.frames[prev]
        if span <= 0:
            return self._hermite(prev, 0)
        t = (frame - self.frames[prev]) / span
        t2, t3 = t * t, t * t * t
        return ((2 * t3 - 3 * t2 + 1) * self._hermite(prev, 0) + (t3 - 2 * t2 + t) * span * self._hermite(prev, 2)
                + (-2 * t3 + 3 * t2) * self._hermite(index, 0) + (t3 - t2) * span * self._hermite(index, 1))

    def decode_rotation(self, key):
        stride = ROTATION_STRIDE.get(self.type)
        if stride is None:
            raise FarcError(f"unsupported MOT rotation channel 0x{self.type:02X}")
        offset = key * stride
        if offset + stride > len(self.packed):
            raise FarcError("packed MOT rotation key is truncated")
        p = self.packed
        t = self.type
        if t in (14, 15):
            value = struct.unpack_from("<Q", p, offset)[0]
            x = (((value >> 42) & 0x1FFFFF) - 1048576.0) / 1048576.0
            y = (((value >> 21) & 0x1FFFFF) - 1048576.0) / 1048576.0
            z = ((value & 0x1FFFFF) - 1048576.0) / 1048576.0
            w = max(0.0, 1.0 - x * x - y * y - z * z) ** 0.5
            if t == 15 and value & 0x8000000000000000:
                w = -w
            return _check_quat((x, y, z, w))
        if t == 16:
            x, y, z = ((v - 32768.0) / 32768.0 for v in struct.unpack_from("<3H", p, offset))
            return _check_quat((x, y, z, max(0.0, 1.0 - x * x - y * y - z * z) ** 0.5))
        if t in (17, 18):
            value = int.from_bytes(p[offset:offset + 6], "little")
            scale = 23169.06
            if t == 17:
                a = (((value >> 32) & 0x7FFF) - 16384.0) / scale
                b = (((value >> 17) & 0x7FFF) - 16384.0) / scale
                c = (((value >> 2) & 0x7FFF) - 16384.0) / scale
                return _compose_smallest_three(value & 3, a, b, c, True)
            a = (((value >> 33) & 0x7FFF) - 16384.0) / scale
            b = (((value >> 18) & 0x7FFF) - 16384.0) / scale
            c = (((value >> 3) & 0x7FFF) - 16384.0) / scale
            return _compose_smallest_three(value & 3, a, b, c, (value & 4) == 0)
        if t == 19:
            value = struct.unpack_from("<I", p, offset)[0]
            scale = 512.0 * 2 ** 0.5
            a = (((value >> 22) & 0x3FF) - 512.0) / scale
            b = (((value >> 12) & 0x3FF) - 512.0) / scale
            c = (((value >> 2) & 0x3FF) - 512.0) / scale
            return _compose_smallest_three(value & 3, a, b, c, True)
        if t == 20:
            return _check_quat(struct.unpack_from("<4f", p, offset))
        if t == 21:
            return _check_quat(struct.unpack_from("<4e", p, offset))
        if t in (22, 23):
            import math
            vector = struct.unpack_from("<3e" if t == 23 else "<3f", p, offset)
            if not _finite(*vector):
                raise FarcError("MOT logarithmic rotation is not finite")
            length = math.sqrt(sum(v * v for v in vector))
            if length <= 1e-12:
                return QUAT_IDENTITY
            factor = math.sin(length) / length
            return _check_quat((vector[0] * factor, vector[1] * factor, vector[2] * factor, math.cos(length)))
        x, y, z = struct.unpack_from("<3f", p, offset)  # 24: Euler XYZ
        if not _finite(x, y, z):
            raise FarcError("MOT Euler rotation is not finite")
        return _quat_from_euler_xyz(x, y, z)

    def evaluate_rotation(self, frame):
        if not self.frames:
            return QUAT_IDENTITY
        if len(self.frames) == 1:
            return self.decode_rotation(0)
        index = _upper_bound(self.frames, int(frame))
        if index <= 0:
            return self.decode_rotation(0)
        if index >= len(self.frames):
            return self.decode_rotation(len(self.frames) - 1)
        prev = index - 1
        span = self.frames[index] - self.frames[prev]
        t = (frame - self.frames[prev]) / span if span > 0 else 0.0
        first, second = self.decode_rotation(prev), self.decode_rotation(index)
        return _shortest_lerp(first, second, t) if self.key_type == 5 else _shortest_slerp(first, second, t)


class BoneTrack:
    __slots__ = ("bone", "parent", "name", "channels")

    def __init__(self, bone, parent, name, channels):
        self.bone = bone
        self.parent = parent
        self.name = name
        self.channels = channels

    def find(self, channel_type):
        for channel in self.channels:
            if channel.type == channel_type:
                return channel
        return None

    def find_rotation(self):
        for channel in self.channels:
            if channel.is_rotation:
                return channel
        return None


class Motion:
    __slots__ = ("name", "skeleton", "frame_count", "joint_type", "tracks")

    def __init__(self, name, skeleton, frame_count, joint_type, tracks):
        self.name = name
        self.skeleton = skeleton
        self.frame_count = frame_count
        self.joint_type = joint_type
        self.tracks = tracks


def _u16(d, o): return struct.unpack_from("<H", d, o)[0]
def _i16(d, o): return struct.unpack_from("<h", d, o)[0]
def _u32(d, o): return struct.unpack_from("<I", d, o)[0]
def _align(value, alignment): return (value + alignment - 1) & ~(alignment - 1)


def _check_range(d, offset, length, label):
    if offset < 0 or length < 0 or offset + length > len(d):
        raise FarcError(f"{label} exceeds the stream")


def _cstring(d, offset, length, label):
    _check_range(d, offset, length + 1, label)
    if d[offset + length] != 0:
        raise FarcError(f"{label} is not NUL terminated")
    return bytes(d[offset:offset + length]).decode("utf-8", "replace")


def _value_stride(channel_type, key_type):
    if key_type in (2, 3):
        return 4
    if key_type == 4:
        return 12
    if key_type in (5, 6) and _is_rotation(channel_type):
        return ROTATION_STRIDE[channel_type]
    raise FarcError(f"unsupported MOT dynamic key type {key_type}")


def _parse_channel(d, start, end):
    if start < 0 or end < start + 8 or end > len(d):
        raise FarcError("MOT channel range is invalid")
    channel_type, key_type = _u16(d, start), _u16(d, start + 2)
    reserved = _u32(d, start + 4)
    if key_type == 0:
        return MotionChannel(channel_type, 0, [], [], b"")
    if key_type == 1:
        if _is_rotation(channel_type):
            stride = ROTATION_STRIDE.get(channel_type)
            if stride is None:
                raise FarcError(f"unsupported MOT rotation channel 0x{channel_type:02X}")
            _check_range(d, start + 8, stride, "MOT static rotation")
            return MotionChannel(channel_type, 1, [0], [], bytes(d[start + 8:start + 8 + stride]))
        _check_range(d, start + 8, 4, "MOT static value")
        value = struct.unpack_from("<f", d, start + 8)[0]
        if not _finite(value):
            raise FarcError("MOT static scalar is not finite")
        return MotionChannel(channel_type, 1, [0], [value], b"")
    if key_type in (2, 3, 4, 5, 6):
        _check_range(d, start + 8, 4, "MOT dynamic channel header")
        count = _u16(d, start + 8)
        if count <= 0:
            raise FarcError("MOT dynamic channel has no keys")
        stride = _value_stride(channel_type, key_type)
        alignment = 4 if key_type in (2, 3, 4) or channel_type in (20, 22, 24) else 2
        time_encoding = reserved & 0xFF
        width = {0: 1, 1: 2, 2: 4}.get(time_encoding)
        if width is None:
            raise FarcError(f"unsupported MOT time encoding {time_encoding}")
        _check_range(d, start + 12, count * width, "MOT timetable")
        fmt = {1: "B", 2: "h" if time_encoding == 2 else "H", 4: "i"}[width]
        frames = list(struct.unpack_from(f"<{count}{fmt}", d, start + 12))
        values_at = _align(start + 12 + count * width, alignment)
        if key_type in (4, 5, 6):
            length = count * stride
            if values_at < 0 or values_at > end:
                raise FarcError("MOT dynamic value range is invalid")
            available = min(length, end - values_at)
            missing = length - available
            if missing > 0 and (channel_type != 23 or missing > 2):
                raise FarcError("MOT dynamic value payload is truncated")
            _check_range(d, values_at, available, "MOT dynamic values")
            return MotionChannel(channel_type, key_type, frames, [], bytes(d[values_at:values_at + available]) + b"\0" * missing)
        if values_at + count * 4 > end:
            raise FarcError("MOT scalar keys exceed their channel")
        scalars = list(struct.unpack_from(f"<{count}f", d, values_at))
        if not _finite(*scalars):
            raise FarcError("MOT scalar key is not finite")
        return MotionChannel(channel_type, key_type, frames, scalars, b"")
    return MotionChannel(channel_type, key_type, [], [], bytes(d[start + 8:max(start + 8, end)]))


def _relative_offsets(d, table, count, end, label):
    _check_range(d, table, count * 4, label + " offset table")
    offsets, floor = [], table + count * 4
    for i in range(count):
        target = table + _u32(d, table + i * 4)
        if target < floor or target >= end:
            raise FarcError(f"{label} {i} offset is invalid")
        offsets.append(target)
        floor = target
    return offsets


def parse_motion(data, name):
    d = memoryview(data)
    if len(d) < 32 or bytes(d[0:4]) != b"#MOT":
        raise FarcError("not a valid #MOT stream")
    if d[15] != 10:
        raise FarcError("#MOT uses an unsupported container header")
    if _u32(d, 16) != MOT_VERSION:
        raise FarcError(f"unsupported #MOT version 0x{_u32(d, 16):08X}")
    frame_count, count, joint_type, name_length = _u32(d, 20), _u16(d, 24), d[26], d[27]
    if not 0 < count <= 100_000:
        raise FarcError(f"#MOT element count is invalid: {count}")
    if joint_type > 11:
        raise FarcError(f"#MOT joint type is invalid: {joint_type}")
    skeleton = _cstring(d, 32, name_length, "#MOT skeleton name")
    offsets = _relative_offsets(d, _align(32 + name_length + 1, 4), count, len(d), "#MOT element")
    by_bone = [None] * count
    for i, start in enumerate(offsets):
        end = offsets[i + 1] if i + 1 < count else len(d)
        _check_range(d, start, 12, f"#MOT record {i}")
        bone, parent, _flags, channel_count = _u16(d, start), _i16(d, start + 2), _u16(d, start + 4), _u16(d, start + 6)
        bone_name_length, alias_count = d[start + 8], d[start + 9]
        if channel_count > 4096:
            raise FarcError(f"#MOT bone {bone} channel count is invalid")
        if d[start + 10] or d[start + 11]:
            raise FarcError(f"#MOT bone {bone} has unsupported record flags")
        bone_name = _cstring(d, start + 12, bone_name_length, f"#MOT bone {bone} name")
        if not bone_name.strip():
            raise FarcError(f"#MOT bone {bone} has no name")
        cursor = start + 12 + bone_name_length + 1
        for a in range(alias_count):
            _check_range(d, cursor, 2, f"#MOT bone {bone} alias {a}")
            alias_length = d[cursor + 1]
            if not _cstring(d, cursor + 2, alias_length, f"#MOT bone {bone} alias {a}").strip():
                raise FarcError(f"#MOT bone {bone} alias {a} is empty")
            cursor += 2 + alias_length + 1
        table = _align(cursor, 4)
        if table + channel_count * 4 > end:
            raise FarcError(f"#MOT bone {bone} channel table is truncated")
        starts, floor = [], table + channel_count * 4
        for c in range(channel_count):
            target = table + _u32(d, table + c * 4)
            if target < floor or target + 8 > end:
                raise FarcError(f"#MOT bone {bone} channel {c} offset is invalid")
            starts.append(target)
            floor = target
        channels = [_parse_channel(d, s, starts[c + 1] if c + 1 < channel_count else end) for c, s in enumerate(starts)]
        if bone >= count:
            raise FarcError(f"#MOT record {i} has out-of-range bone id {bone}")
        if by_bone[bone] is not None:
            raise FarcError(f"#MOT contains duplicate bone id {bone}")
        by_bone[bone] = BoneTrack(bone, parent, bone_name, channels)
    for j, track in enumerate(by_bone):
        if track is None:
            raise FarcError(f"#MOT is missing bone id {j}")
        if track.parent < -1 or track.parent >= count or track.parent == j:
            raise FarcError(f"#MOT bone {j} has invalid parent {track.parent}")
    state = [0] * count
    for start_bone in range(count):
        stack = [start_bone]
        path = []
        while stack:
            bone = stack.pop()
            if state[bone] == 2:
                continue
            if state[bone] == 1:
                raise FarcError(f"#MOT hierarchy contains a cycle at bone {bone}")
            state[bone] = 1
            path.append(bone)
            if by_bone[bone].parent >= 0:
                stack.append(by_bone[bone].parent)
        for bone in path:
            state[bone] = 2
    return Motion(name, skeleton, frame_count, joint_type, by_bone)


def _normalize_joint(value):
    return value if value <= 5 else value - 6


def is_compatible(motion, joint_type, bones):
    """bones: [(index, parent, name)] as reported by the game."""
    if not 0 <= joint_type <= 11 or not motion.tracks or \
            _normalize_joint(joint_type) != _normalize_joint(motion.joint_type) or len(bones) != len(motion.tracks):
        return False
    by_index = [None] * len(bones)
    for index, parent, bone_name in bones:
        if not 0 <= index < len(by_index) or by_index[index] is not None or not bone_name:
            return False
        by_index[index] = (parent, bone_name)
    for track in motion.tracks:
        if not 0 <= track.bone < len(by_index):
            return False
        parent, bone_name = by_index[track.bone]
        if parent != track.parent or bone_name != track.name:
            return False
    return True


def sample_pose(motion, frame, baseline):
    """10 floats per bone (quat x,y,z,w; channels 0-2; channels 6-8) over the
    game-supplied baseline, like PhotoBodyMotionCatalog.Sample."""
    if not _finite(frame) or len(baseline) != len(motion.tracks) * 10:
        raise ValueError("the animation time or the original pose is not valid")
    out = list(baseline)
    frame = max(0.0, min(float(frame), float(max(0, motion.frame_count - 1))))
    for track in motion.tracks:
        base = track.bone * 10
        for i in range(3):
            channel = track.find(i)
            if channel is not None and channel.has_scalar_payload:
                out[base + 4 + i] = channel.evaluate_scalar(frame)
            channel = track.find(i + 6)
            if channel is not None and channel.has_scalar_payload:
                out[base + 7 + i] = channel.evaluate_scalar(frame)
        rotation = track.find_rotation()
        if rotation is not None and rotation.frames and rotation.packed:
            out[base:base + 4] = rotation.evaluate_rotation(frame)
    if not _finite(*out):
        raise FarcError("the motion pose holds values that are not finite numbers")
    return out


def motion_archive_path(app_root, token):
    return Path(app_root) / "rom" / "mot" / f"mot_{token.lower()}.farc"


def list_body_motions(app_root, token, joint_type, bones):
    """[(entry_name, display_name, frame_count)] of motions fitting this rig."""
    if any(c in token for c in '/\\:*?"<>|'):
        raise FarcError("the character asset name is not valid")
    archive = FarcArchive(motion_archive_path(app_root, token))
    result = []
    for entry in archive.matching(".mot"):
        try:
            motion = parse_motion(archive.read(entry), entry.name)
        except (FarcError, struct.error):
            continue
        if is_compatible(motion, joint_type, bones):
            display = Path(entry.name.replace("\\", "/")).stem
            result.append((entry.name, display, motion.frame_count))
    return result


def load_body_motion(app_root, token, entry_name, joint_type, bones):
    archive = FarcArchive(motion_archive_path(app_root, token))
    entry = next((e for e in archive.entries if e.name == entry_name), None)
    if entry is None:
        raise FarcError("that motion is no longer in the archive")
    motion = parse_motion(archive.read(entry), entry.name)
    if not is_compatible(motion, joint_type, bones):
        raise FarcError("this motion does not fit the character's skeleton")
    return motion


def load_weapon_clips(app_root, token, entry_name, rigs):
    """rigs: [dict(slot, rig, mesh, pose, name, joint_type, bones, baseline)] ->
    [(rig, motion)] for weapon motions named <body motion>_<weapon rig>.mot."""
    archive = FarcArchive(motion_archive_path(app_root, token))
    prefix = entry_name[:-4] + "_"
    clips = []
    for rig in rigs:
        wanted = (prefix + rig["name"] + ".mot").lower()
        matches = [e for e in archive.entries if e.name.lower() == wanted]
        if len(matches) != 1:
            continue
        motion = parse_motion(archive.read(matches[0]), matches[0].name)
        if is_compatible(motion, rig["joint_type"], rig["bones"]):
            clips.append((rig, motion))
    return clips
