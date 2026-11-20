# Game view — what to expect and how to confirm it

This page describes the visible state of a **known-good run** so you can compare
your own installation without needing to interpret raw diagnostics.

## Before the map loads

- SteamVR shows **MWR VR** in its application list. If it does not, the manifest
  registration step in `docs/INSTALL_2019_1_15.md` was not applied.
- `overlord.exe` opens a desktop launcher. Choose **Singleplayer**.
- The game window appears but stays black or static for roughly two minutes
  while assets unpack. This is expected.
- A campaign autosave warning popup may appear. Dismiss it before continuing.

## After `map killhouse`

When the level is actually running, all of the following should be true:

| What you observe | Why it matters |
| --- | --- |
| The killhouse environment is rendered in stereo (separate left/right eye views). | Confirms stereo rendering is active. |
| Head movement changes the view immediately. | Confirms 6DOF head tracking. |
| Native menus and HUD appear inside VR rather than only on the desktop. | Confirms VR menu integration. |
| Controllers are visible or can bring up weapon interaction. | Confirms hand tracking and bindings. |
| The game is not stuck on a loading screen or the frontend menu. | Confirms the map actually loaded. |

## Diagnostic confirmation

Press **Ctrl+Shift+F8** with the game window focused, or run `vr_diagnose` in
the console. After about five seconds, a diagnostic ZIP opens. Check the status
section. A good run contains:

```text
target_ready=yes environment="Singleplayer" scene_initialized=yes frontend=no
mapname="killhouse"
sv_running=yes
cl_paused=0
```

The console tail should include stereo eye target messages such as:

```text
[VR] isolated outer-owner left eye returned with final scene target captured
[VR] isolated outer-owner right eye returned with final scene target captured
```

and VR menu / interaction activity, for example:

```text
[VR menus] stack: sp_pause_menu
[VR interaction] native pickup icon layout rejected
```

`cl_ingame=unavailable` is acceptable. That symbol is unresolved in this build;
the other fields already prove the level is loaded and the scene initialized.

## Language

English assets are selected when `zone\_russian` exists and `zone\russian` does
not. The log then shows English paths. To switch back, run `Change language.bat`
in the game folder or rename the folder manually.

## Failure signatures

| Symptom | Likely cause |
| --- | --- |
| Crash within seconds of launch, fault near `0x343E06` | Wrong loader — a 2016-derived build using `Cmd_AddCommandInternal` at `0x140343E00`. Use the `overlord.exe` in this kit. |
| Game never leaves frontend | Map command not applied, or wrong client version. |
| `target_ready=no` | SteamVR/headset not ready before launch. |
| Russian audio/text | Language folder not switched. |

If you see a failure signature, do not debug by changing addresses. Verify the
game hash first, then reinstall this kit.
