# Verification evidence

This page records exactly what was checked and what was observed. It is written
so another person can repeat the check.

## Target identity

Before testing, `h1_sp64_ship.exe` was read from the installed game folder:

| Property | Value |
| --- | --- |
| Size | 20213128 bytes (`0x1346D88`) |
| PE timestamp | `0x5D374DBA` (2019-07-23 18:11:06 UTC) |
| PE format | x64, PE32+, 11 sections |
| Image size | `0x12654800` |
| Entry RVA | `0x6D56E0` |
| SHA-256 | `3d23e86930668244d43a026552d5e1298a7c8cc63b82a54a7ad857e7b41f9190` |

## Why the old loader failed

The 2016 retarget build changed `Cmd_AddCommandInternal` from `0x140376A40`
(2019) to `0x140343E00` (2016). Against the 2019 client it raised an access
violation at fault offset `0x343E06`, inside that function. This is an address
mismatch, not a runtime bug to be worked around.

## What was changed for the verified build

An isolated worktree was created at source commit `6e88fe0`, the last clean
pre-retarget baseline. Its `image.hpp` already expected the 2019 identity above.
Generated project files, generated `zconf.h` and dependencies were synced from
the working tree, and the client was built in Release x64.

The resulting `overlord.exe` was checked to contain `0x140376A40` and not
`0x140343E00`. Its SHA-256 is:

```text
a5d5dc9c30156b3ed11bf5d9dc30180ada39341d08036b6d377ff041849d7956
```

## Runtime observation

The build was deployed next to the game, SteamVR was started, and Singleplayer
was selected. After startup, `map killhouse` was entered in the console.

A diagnostic bundle was produced with the diagnostic hotkey. Its status file
contained:

```text
target_ready=yes environment="Singleplayer" scene_initialized=yes frontend=no
mapname="killhouse"
cl_ingame=unavailable
sv_running=yes
cl_paused=0
```

The console tail contained stereo eye-target messages, VR menu stack changes and
VR interaction events, confirming that rendering and interaction hooks were
active while the level was loaded.

## What this does and does not prove

It proves that the exact binary in `files/overlord.exe`, used with the exact
2019/1.15 client hash above, reaches a loaded level with VR systems active.

It does **not** prove:

- compatibility with the 2016 client or any other build,
- that every Overlord feature works in every mission,
- that the 2016-derived retarget is usable.

Those remain separate, unverified claims.
