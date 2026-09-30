/* Bridge between the Linux GUI and fgohook's photo-mode shared memory.
 *
 * fgohook.dll creates named file mappings (pid = ago.exe's Windows process id):
 *   Local\FGOLocalPhoto_<pid>       camera   "FGOP" v2, 80 bytes
 *   Local\FGOLocalPhotoFace_<pid>   face     "FGCE" v1, 5416 bytes
 *   Local\FGOLocalPhotoBody_<pid>   body     "FGCB" v2, 273576 bytes
 *   Local\FGOLocalPhotoModel_<pid>  model    "FGPM" v6, 856 bytes
 * scooby's Photo window writes into them. A native Linux process can't open a
 * Wine named section, so this console program runs under the same wine/prefix
 * as the game and relays line commands (one JSON reply per line):
 *
 *   status                             -> {"connected":..,"active":..,"fov":..,"pos":[x,y,z]}
 *   cmd <1|2|4>                        camera: 1 enter/exit, 2 reset camera, 4 resume game
 *   speed <float> | fov <float>        camera move speed / field of view (fov applied via cmd 8)
 *   dof <0|1> <focus> <range> <falloff> <blur>
 *   read <block> <offset> <length>     -> {"ok":true,"hex":"..."}
 *   write <block> <offset> <hex>       raw bytes; offsets 0-7 (magic/version) are refused
 *   quit
 *
 * Camera layout (scooby PhotoWindow.cs): +8 command, +12 in-photo flag, +16
 * current FOV, +32/36/40 camera position, +44 speed, +48 FOV to apply, +52 DOF
 * on, +56 focus, +60 focus range, +64 falloff, +68 blur radius. The face/body/
 * model layouts live in linux/tools/fgo_gui.py / photo_assets.py.
 */
#include <windows.h>
#include <tlhelp32.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <wchar.h>

enum { CAMERA, FACE, BODY, MODEL, BLOCKS };

static const struct {
    const char *name;
    const wchar_t *prefix;
    LONG magic;
    LONG version;
    DWORD size;
} spec[BLOCKS] = {
    {"camera", L"Local\\FGOLocalPhoto_", 0x504F4746, 2, 80},
    {"face", L"Local\\FGOLocalPhotoFace_", 0x45434746, 1, 5416},
    {"body", L"Local\\FGOLocalPhotoBody_", 0x42434746, 2, 273576},
    {"model", L"Local\\FGOLocalPhotoModel_", 0x4D504746, 6, 856},
};

static HANDLE mapping[BLOCKS];
static unsigned char *view[BLOCKS];
static DWORD connected_pid;

static void close_block(int b)
{
    if (view[b]) UnmapViewOfFile(view[b]);
    if (mapping[b]) CloseHandle(mapping[b]);
    view[b] = NULL;
    mapping[b] = NULL;
}

static void disconnect(void)
{
    for (int b = 0; b < BLOCKS; b++) close_block(b);
    connected_pid = 0;
}

static DWORD find_game_pid(void)
{
    DWORD pid = 0;
    HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (snapshot == INVALID_HANDLE_VALUE) return 0;
    PROCESSENTRY32W entry;
    entry.dwSize = sizeof(entry);
    if (Process32FirstW(snapshot, &entry)) {
        do {
            if (_wcsicmp(entry.szExeFile, L"ago.exe") == 0) {
                pid = entry.th32ProcessID;
                break;
            }
        } while (Process32NextW(snapshot, &entry));
    }
    CloseHandle(snapshot);
    return pid;
}

static int valid(int b)
{
    return view[b] && *(volatile LONG *)(view[b] + 0) == spec[b].magic &&
           *(volatile LONG *)(view[b] + 4) == spec[b].version;
}

/* Opens block b of the current ago.exe (reconnecting after a game restart). */
static int open_block(int b)
{
    DWORD pid = find_game_pid();
    if (pid == 0) {
        disconnect();
        return 0;
    }
    if (pid != connected_pid) {
        disconnect();
        connected_pid = pid;
    }
    if (valid(b)) return 1;
    close_block(b);
    wchar_t name[80];
    swprintf(name, 80, L"%ls%lu", spec[b].prefix, (unsigned long)pid);
    mapping[b] = OpenFileMappingW(FILE_MAP_ALL_ACCESS, FALSE, name);
    if (!mapping[b]) return 0;
    view[b] = MapViewOfFile(mapping[b], FILE_MAP_ALL_ACCESS, 0, 0, spec[b].size);
    if (!view[b] || !valid(b)) {
        close_block(b);
        return 0;
    }
    return 1;
}

static int block_index(const char *name)
{
    for (int b = 0; b < BLOCKS; b++)
        if (strcmp(name, spec[b].name) == 0) return b;
    return -1;
}

static float read_float(int offset) { return *(volatile float *)(view[CAMERA] + offset); }
static void write_float(int offset, float value) { *(volatile float *)(view[CAMERA] + offset) = value; }
static void write_int(int offset, LONG value) { *(volatile LONG *)(view[CAMERA] + offset) = value; }
static float clampf(float value, float lo, float hi) { return value < lo ? lo : (value > hi ? hi : value); }

static void reply(int ok, const char *error)
{
    if (ok) printf("{\"ok\":true}\n");
    else printf("{\"ok\":false,\"error\":\"%s\"}\n", error);
}

static void reply_status(void)
{
    if (!open_block(CAMERA)) {
        printf("{\"connected\":false}\n");
        return;
    }
    printf("{\"connected\":true,\"pid\":%lu,\"active\":%s,\"fov\":%.3f,\"pos\":[%.3f,%.3f,%.3f]}\n",
           (unsigned long)connected_pid, *(volatile LONG *)(view[CAMERA] + 12) ? "true" : "false",
           read_float(16), read_float(32), read_float(36), read_float(40));
}

static int hex_value(char c)
{
    if (c >= '0' && c <= '9') return c - '0';
    if (c >= 'a' && c <= 'f') return c - 'a' + 10;
    if (c >= 'A' && c <= 'F') return c - 'A' + 10;
    return -1;
}

static void do_read(char *args)
{
    char name[16];
    unsigned long offset, length;
    if (sscanf(args, "%15s %lu %lu", name, &offset, &length) != 3) return reply(0, "bad read");
    int b = block_index(name);
    if (b < 0) return reply(0, "unknown block");
    if (offset > spec[b].size || length > spec[b].size - offset) return reply(0, "out of range");
    if (!open_block(b)) return reply(0, "not connected");
    static const char digits[] = "0123456789abcdef";
    fputs("{\"ok\":true,\"hex\":\"", stdout);
    for (unsigned long i = 0; i < length; i++) {
        unsigned char v = ((volatile unsigned char *)view[b])[offset + i];
        putchar(digits[v >> 4]);
        putchar(digits[v & 15]);
    }
    fputs("\"}\n", stdout);
}

static void do_write(char *args)
{
    char name[16];
    unsigned long offset;
    int consumed = 0;
    if (sscanf(args, "%15s %lu %n", name, &offset, &consumed) != 2 || consumed == 0) return reply(0, "bad write");
    int b = block_index(name);
    if (b < 0) return reply(0, "unknown block");
    char *hex = args + consumed;
    size_t n = strcspn(hex, "\r\n ");
    if (n == 0 || n % 2) return reply(0, "bad hex");
    size_t length = n / 2;
    if (offset < 8 || offset > spec[b].size || length > spec[b].size - offset) return reply(0, "out of range");
    for (size_t i = 0; i < n; i++)
        if (hex_value(hex[i]) < 0) return reply(0, "bad hex");
    if (!open_block(b)) return reply(0, "not connected");
    for (size_t i = 0; i < length; i++)
        ((volatile unsigned char *)view[b])[offset + i] = (unsigned char)(hex_value(hex[2 * i]) << 4 | hex_value(hex[2 * i + 1]));
    reply(1, NULL);
}

#define LINE_MAX_BYTES (4 * 1024 * 1024)

int main(void)
{
    static char line[LINE_MAX_BYTES];
    setvbuf(stdout, NULL, _IOFBF, 1 << 20);
    while (fgets(line, sizeof(line), stdin)) {
        char verb[16] = {0};
        int consumed = 0;
        if (sscanf(line, "%15s %n", verb, &consumed) < 1) continue;
        char *args = line + consumed;
        float a = 0, b = 0, c = 0, d = 0, e = 0;
        int n = sscanf(args, "%f %f %f %f %f", &a, &b, &c, &d, &e);
        if (strcmp(verb, "quit") == 0) break;
        if (strcmp(verb, "status") == 0) reply_status();
        else if (strcmp(verb, "read") == 0) do_read(args);
        else if (strcmp(verb, "write") == 0) do_write(args);
        else if (!open_block(CAMERA)) reply(0, "not connected");
        else if (strcmp(verb, "cmd") == 0 && n == 1 && (a == 1 || a == 2 || a == 4)) {
            write_int(8, (LONG)a);
            reply(1, NULL);
        } else if (strcmp(verb, "speed") == 0 && n == 1) {
            write_float(44, clampf(a, 0.05f, 10.0f));
            reply(1, NULL);
        } else if (strcmp(verb, "fov") == 0 && n == 1) {
            write_float(48, clampf(a, 5.0f, 150.0f));
            write_int(8, 8);
            reply(1, NULL);
        } else if (strcmp(verb, "dof") == 0 && n == 5) {
            write_float(56, clampf(b, 0.1f, 100.0f));
            write_float(60, clampf(c, 0.0f, 20.0f));
            write_float(64, clampf(d, 0.01f, 50.0f));
            write_float(68, clampf(e, 0.0f, 8.0f));
            write_int(52, a != 0 ? 1 : 0);
            reply(1, NULL);
        } else reply(0, "bad command");
        fflush(stdout);
    }
    disconnect();
    return 0;
}
