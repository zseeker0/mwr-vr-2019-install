# New PC walkthrough — game, mod, then this kit

Follow these phases in order. Each phase ends with a check so you know it is
safe to continue.

---

## Phase 1 — Install the game

1. Install Steam and sign in with an account that legally owns *Call of Duty:
   Modern Warfare Remastered*.
2. In Steam, install the game. Note the install folder. If you later need to
   find it: Steam → Settings → Storage, or right-click the game → Properties →
   Installed Files → Browse.
3. Launch the game once through Steam so it creates its configuration and
   verifies its files.
4. Close the game completely.
5. Verify the client identity. Open PowerShell in the game folder (the one
   containing `h1_sp64_ship.exe`) and run:

   ```powershell
   Get-Item 'h1_sp64_ship.exe' | Select-Object Length
   Get-FileHash 'h1_sp64_ship.exe' -Algorithm SHA256
   ```

   Expected:

   | Property | Value |
   | --- | --- |
   | Size | `20213128` bytes |
   | SHA-256 | `3d23e86930668244d43a026552d5e1298a7c8cc63b82a54a7ad857e7b41f9190` |

6. **If the hash matches**, continue to Phase 2.
   **If it does not match**, stop. This kit was not validated for that build and
   applying it may crash the game. Steam may have installed a different client
   version; do not work around it by changing addresses.

---

## Phase 2 — Install the Overlord mod normally

1. Install SteamVR through Steam and run it once. Connect your headset and both
   controllers, and confirm SteamVR reports them as tracked.
2. Download the latest MWR VR release from
   [lesan0622/MWR-VR releases](https://github.com/lesan0622/MWR-VR/releases).
3. Install it the normal way — either:
   - **Installer (recommended):** run `MWR-VR-Setup.exe`, point it at the game
     folder from Phase 1, and accept the prompts; or
   - **Manual:** extract the release ZIP into the game folder so that
     `overlord.exe`, `openxr_loader.dll`, `overlord.vrmanifest`, `overlord-mwr/`,
     `vr_input/` and `steamvr/` sit next to `h1_sp64_ship.exe`.
4. Do **not** launch the mod yet. Its bundled loader is the version that will be
   replaced in Phase 3.
5. Check that these folders now exist in the game folder:
   `overlord-mwr/`, `vr_input/`, `steamvr/`. If any are missing, redo the mod
   installation before continuing.

---

## Phase 3 — Apply this kit

1. Make sure the game, the MWR launcher and SteamVR are all closed.
2. Copy or clone this repository anywhere convenient. It does not need to live
   in the game folder.
3. Open PowerShell in the repository root and run:

   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts\install.ps1
   ```

4. Select the game folder when prompted. The script will:
   - re-check the game hash and refuse to continue on a mismatch;
   - back up any existing mod files into a timestamped folder;
   - copy the verified `overlord.exe`, `openxr_loader.dll`, `tlsdll.dll`,
     `overlord.vrmanifest`, `vr_input/` and `steamvr/` files;
   - verify every copied hash;
   - switch the locale to English by renaming `zone\russian` to
     `zone\_russian` (reversible).
5. Confirm with:

   ```powershell
   powershell -ExecutionPolicy Bypass -File scripts\verify.ps1
   ```

   You should see `VERIFY_OK`.

6. If the mod does not appear in SteamVR, register its manifest once:

   ```powershell
   & '<steam-root>\steamapps\common\SteamVR\bin\win64\vrpathreg.exe' addmanifest '<game-folder>\overlord.vrmanifest'
   ```

   Then restart SteamVR.

---

## Phase 4 — First run and confirmation

1. Start SteamVR. Confirm headset and controllers are tracked.
2. Run `overlord.exe` from the game folder and choose **Singleplayer**.
3. Allow roughly two minutes for unpacking before the window responds. Dismiss
   any autosave warning popup.
4. Open the in-game console and run:

   ```text
   map killhouse
   ```

5. Compare the result with `docs/GAME_VIEW.md`. For a hard confirmation, press
   **Ctrl+Shift+F8** or run `vr_diagnose` in the console and check that the
   status file contains:

   ```text
   target_ready=yes environment="Singleplayer" scene_initialized=yes frontend=no
   mapname="killhouse"
   sv_running=yes
   ```

---

## Reverting

To undo Phase 3 and return to the files installed in Phase 2:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\restore.ps1
```

This restores the backups made by `install.ps1`. It does not remove the game,
the mod's other folders, or any saves.
