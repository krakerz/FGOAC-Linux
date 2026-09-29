/* Bridge between the Linux GUI and fgohook's photo-mode shared memory.
 *
 * fgohook.dll creates a named file mapping `Local\FGOLocalPhoto_<pid>` (80
 * bytes, pid = ago.exe's Windows process id). scooby's Photo window writes
 * camera speed / FOV / depth of field and commands into it. A native Linux
 * process can't open a Wine named section, so this tiny console program runs
 * under the same wine/prefix as the game and relays line commands:
 *
 *   status                        -> {"connected":..,"active":..,"fov":..,"pos":[x,y,z]}
 *   cmd <1|2|4>                   1 = enter/exit photo mode, 2 = reset camera, 4 = resume game
 *   speed <float>                 camera move speed (0.05..10)
 *   fov <float>                   field of view in degrees (5..150), applied via cmd 8
 *   dof <0|1> <focus> <range> <falloff> <blur>
 *   quit
 *
 * Every reply is one JSON line. Layout (scooby PhotoWindow.cs): +0 magic
 * "FGOP" 0x504F4746, +4 version 2, +8 command, +12 in-photo flag, +16 current
 * FOV, +32/36/40 camera position, +44 speed, +48 FOV to apply, +52 DOF on,
 * +56 focus, +60 focus range, +64 falloff, +68 blur radius.
 */
#include <windows.h>
#include <tlhelp32.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <wchar.h>

#define PHOTO_MAGIC 0x504F4746
#define PHOTO_VERSION 2
#define PHOTO_SIZE 80

static HANDLE mapping;
static unsigned char *view;
static DWORD connected_pid;

static void disconnect(void)
{
    if (view) UnmapViewOfFile(view);
    if (mapping) CloseHandle(mapping);
    view = NULL;
    mapping = NULL;
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

static int alive(void)
{
    return view && *(volatile LONG *)(view + 0) == PHOTO_MAGIC && *(volatile LONG *)(view + 4) == PHOTO_VERSION;
}

/* (Re)connects to the current ago.exe's mapping; returns 1 when usable. */
static int ensure_connected(void)
{
    DWORD pid = find_game_pid();
    if (pid == 0) {
        disconnect();
        return 0;
    }
    if (pid == connected_pid && alive()) return 1;
    disconnect();
    wchar_t name[64];
    swprintf(name, 64, L"Local\\FGOLocalPhoto_%lu", (unsigned long)pid);
    mapping = OpenFileMappingW(FILE_MAP_ALL_ACCESS, FALSE, name);
    if (!mapping) return 0;
    view = MapViewOfFile(mapping, FILE_MAP_ALL_ACCESS, 0, 0, PHOTO_SIZE);
    if (!view || !alive()) {
        disconnect();
        return 0;
    }
    connected_pid = pid;
    return 1;
}

static float read_float(int offset) { return *(volatile float *)(view + offset); }
static void write_float(int offset, float value) { *(volatile float *)(view + offset) = value; }
static void write_int(int offset, LONG value) { *(volatile LONG *)(view + offset) = value; }

static float clampf(float value, float lo, float hi) { return value < lo ? lo : (value > hi ? hi : value); }

static void reply_status(void)
{
    if (!ensure_connected()) {
        printf("{\"connected\":false}\n");
        return;
    }
    printf("{\"connected\":true,\"pid\":%lu,\"active\":%s,\"fov\":%.3f,\"pos\":[%.3f,%.3f,%.3f]}\n",
           (unsigned long)connected_pid, *(volatile LONG *)(view + 12) ? "true" : "false",
           read_float(16), read_float(32), read_float(36), read_float(40));
}

static void reply(int ok, const char *error)
{
    if (ok) printf("{\"ok\":true}\n");
    else printf("{\"ok\":false,\"error\":\"%s\"}\n", error);
}

int main(void)
{
    char line[256];
    setvbuf(stdout, NULL, _IONBF, 0);
    while (fgets(line, sizeof(line), stdin)) {
        char verb[16] = {0};
        float a = 0, b = 0, c = 0, d = 0, e = 0;
        int n = sscanf(line, "%15s %f %f %f %f %f", verb, &a, &b, &c, &d, &e);
        if (n < 1) continue;
        if (strcmp(verb, "quit") == 0) break;
        if (strcmp(verb, "status") == 0) {
            reply_status();
            continue;
        }
        if (!ensure_connected()) {
            reply(0, "not connected");
            continue;
        }
        if (strcmp(verb, "cmd") == 0 && n == 2 && (a == 1 || a == 2 || a == 4)) {
            write_int(8, (LONG)a);
            reply(1, NULL);
        } else if (strcmp(verb, "speed") == 0 && n == 2) {
            write_float(44, clampf(a, 0.05f, 10.0f));
            reply(1, NULL);
        } else if (strcmp(verb, "fov") == 0 && n == 2) {
            write_float(48, clampf(a, 5.0f, 150.0f));
            write_int(8, 8);
            reply(1, NULL);
        } else if (strcmp(verb, "dof") == 0 && n == 6) {
            write_float(56, clampf(b, 0.1f, 100.0f));
            write_float(60, clampf(c, 0.0f, 20.0f));
            write_float(64, clampf(d, 0.01f, 50.0f));
            write_float(68, clampf(e, 0.0f, 8.0f));
            write_int(52, a != 0 ? 1 : 0);
            reply(1, NULL);
        } else {
            reply(0, "bad command");
        }
    }
    disconnect();
    return 0;
}
