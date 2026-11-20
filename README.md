# MWR VR — New PC Setup Kit (2019 / 1.15)

A complete, ordered guide for setting up the Overlord VR mod on a fresh Windows
PC, then replacing the mod's loader with the build that was actually verified
against the **2019 / 1.15** single-player client of *Call of Duty: Modern
Warfare Remastered*.

## Why this kit exists

The Overlord mod's 2016-derived build is not compatible with the installed 2019
executable. It was changed to use 2016 function addresses, including
`Cmd_AddCommandInternal` at `0x140343E00` instead of the 2019 address
`0x140376A40`. Against the 2019 client it crashes almost immediately.

This repository contains the rebuilt, verified loader and helper files, plus a
step-by-step guide that goes from an empty PC to a working VR session. It is a
small overlay on top of a normal Overlord installation — not a replacement for
the mod itself.

## The three phases

| Phase | What you do | Where it comes from |
| --- | --- | --- |
| 1. Install the game | Install MWR from Steam and confirm it is the 2019/1.15 build. | Steam |
| 2. Install the mod | Install Overlord for MWR normally (installer or manual ZIP). | [MWR-VR releases](https://github.com/lesan0622/MWR-VR/releases) |
| 3. Apply this kit | Run `scripts/install.ps1` to replace the loader with the verified 2019 build. | This repository |

Do them in that order. Phase 3 assumes Phase 2 already placed the mod's
folders (`overlord-mwr/`, `vr_input/`, `steamvr/`) in the game directory.

## Repository contents

| Path | Purpose |
| --- | --- |
| `docs/NEW_PC_WALKTHROUGH.md` | Start here. Full ordered setup from a fresh PC. |
| `docs/INSTALL_2019_1_15.md` | Detailed Phase 3 steps and identity checks. |
| `docs/FILE_MANIFEST.md` | Exact file list, sizes, hashes and target locations. |
| `docs/GAME_VIEW.md` | What you should see in-game and how to confirm it. |
| `docs/VERIFICATION_EVIDENCE.md` | Raw runtime evidence behind the compatibility claim. |
| `files/overlord.exe` | Verified 2019-compatible VR loader. |
| `files/openxr_loader.dll` | OpenXR runtime loader used by the mod. |
| `files/tlsdll.dll` | TLS helper required by the loader. |
| `files/overlord.vrmanifest` | SteamVR application registration. |
| `files/vr_input/` | Default controller bindings. |
| `files/steamvr/` | SteamVR cover art. |
| `scripts/install.ps1` | Backs up, copies and hash-verifies the files. |
| `scripts/verify.ps1` | Checks installed hashes and locale state. |
| `scripts/restore.ps1` | Restores the pre-install backups. |

## Quick start

If you already completed Phases 1 and 2:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\install.ps1
powershell -ExecutionPolicy Bypass -File scripts\verify.ps1
```

Then start SteamVR, run `overlord.exe`, choose **Singleplayer** and load
`map killhouse`. Compare the result with `docs/GAME_VIEW.md`.

## Compatibility boundary

Verified **only** against `h1_sp64_ship.exe` with SHA-256
`3d23e86930668244d43a026552d5e1298a7c8cc63b82a54a7ad857e7b41f9190`.
The identity check in Phase 1 is mandatory — a hash mismatch means this kit was
not validated for that client and you should stop.

This kit contains no game files and no analysis artifacts. The Ghidra tooling
and 2016 analysis work are published separately in `mwr-analysis-toolkit`.

## Sanitization

No personal paths, usernames, email addresses, credentials or tokens are
included. Compiled binaries contain only generic build-directory strings such
as `C:\games\MWR-VR-2019-baseline\...` inside debug records; no user account
name is embedded.
