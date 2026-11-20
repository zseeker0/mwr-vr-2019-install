# File manifest

All hashes are SHA-256.

## Files copied into the game folder root

| Source in this repo | Target name | Size (bytes) | SHA-256 |
| --- | --- | --- | --- |
| `files/overlord.exe` | `overlord.exe` | 32755200 | `a5d5dc9c30156b3ed11bf5d9dc30180ada39341d08036b6d377ff041849d7956` |
| `files/openxr_loader.dll` | `openxr_loader.dll` | 2113024 | `a7569dc4e999e2664dd3145204e577095067ea2821de05e65fc0474a23b48e` |
| `files/tlsdll.dll` | `tlsdll.dll` | 113152 | `b3aee5f09717b8570bfd2ff80a230e57abcdc6cfe85f781056b55f7558d09cd1` |
| `files/overlord.vrmanifest` | `overlord.vrmanifest` | 473 | see file |

The `overlord.exe` in this kit is the build from source commit `6e88fe0`
(pre-retarget baseline). It contains the 2019 address for
`Cmd_AddCommandInternal` (`0x140376A40`) and does not contain the incompatible
2016 address (`0x140343E00`).

## Files copied into subfolders

| Source | Target | Count |
| --- | --- | --- |
| `files/vr_input/*.json` | `<game>\vr_input\` | 4 |
| `files/steamvr/*.png` | `<game>\steamvr\` | 3 |

## Game version this kit was verified against

| Property | Value |
| --- | --- |
| File | `h1_sp64_ship.exe` |
| Size | 20213128 bytes |
| SHA-256 | `3d23e86930668244d43a026552d5e1298a7c8cc63b82a54a7ad857e7b41f9190` |
| PE timestamp | `0x5D374DBA` |

## Files deliberately NOT included

- The game executable or any other file from the game.
- `decrypted_image.bin` or any memory dump / analysis artifact.
- Crash dumps, diagnostics ZIPs or saved profile data.
- Any source code from the Overlord project (see its own repository/license).

## Backup behaviour

`scripts/install.ps1` writes a timestamped backup folder inside the game
directory before replacing files. `scripts/restore.ps1` reads the most recent
backup. Nothing is overwritten without a backup first.
