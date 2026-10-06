# HANDOFF: personal Quickshell shell (`qs-shell`)

Audience: a fresh agent picking up this work with no prior context. Read this file,
then `MEMORY.md` (decision log) and `CONTRIBUTING.md` (repo rules).

## Goal

This repo is a NixOS + Home Manager flake for a niri laptop ("notebook"), themed with
everforest. The task: a **personal, from-scratch Quickshell config** that replaces the
usual desktop-shell components (bar, notifications, polkit agent, OSD, lock, launcher).
It is deliberately *not* derived from caelestia-shell. Write clean own QML; do not copy
caelestia QML into the new shell.

## Current state (2026-10-06)

`modules/features/quickshell/` = HM config `qs-shell`, spawned at niri startup as
`quickshell -c qs-shell -n` (`default.nix`). It is a single process that owns:

- **Bar** (`qml/modules/bar/Bar.qml`): bottom 18px, one per screen. Clock, niri
  workspaces (`services/Niri.qml`, event-stream driven), battery/volume/mic/power
  profile with click/scroll actions.
- **Notifications** (`services/Notifs.qml`, `modules/notifs/NotifPopups.qml`): own
  `org.freedesktop.Notifications` server, in-memory only. DND/clear via IPC
  (`notifs toggleDnd|clear`, niri binds `Mod+Shift+D`/`Mod+Shift+N`).
- **Polkit agent** (`modules/polkit/PolkitDialog.qml`, `services/Polkit.qml`). If the
  shell dies, elevation prompts wedge until it is restarted.
- **OSD** (`modules/osd/OsdPanel.qml`, `services/Osd.qml`, `Audio.qml`, `Brightness.qml`):
  volume/mic/brightness/power profile. Brightness is a sysfs poll (no inotify on sysfs).
- **Lock** (`services/Lock.qml`, `components/SecretDots.qml`): `WlSessionLock` + PAM
  service `quickshell-lock` (declared in `modules/notebook.nix`), IPC target `lock`.
  Wired to `Super+Alt+L` and swayidle's `lock` event (with a swaylock fallback in
  `lockscreen.nix`). Background is a blurred per-output `grim` screenshot taken before
  the lock engages. Dev switches: `QS_LOCK_TEST=1` (auto-unlock after 30 s),
  `QS_LOCK_CLOCK=seconds`.
- IPC: `powerprofiles cycle` (`Mod+P`), `notifs ...`, `lock lock`. `Mod+Shift+R`
  restarts the whole shell.

Retired: waybar, caelestia-notifs, soteria. The launcher is still **fuzzel**
(`features/launcher.nix`, `Mod+Space`).

Environment facts (verified, do not re-research):

- Quickshell **0.3.1** is in the pinned nixpkgs; niri **26.04**.
- niri supports ext-session-lock, ext-workspace, ext-idle-notify, ext-background-effect
  blur (26.04+).
- Quickshell has **no native niri module**. Use `niri msg` / the event stream. Do not
  copy Hyprland-based examples from upstream docs.
- niri's window JSON has **no `is_fullscreen` field**; fullscreen suppression must be
  approximated or skipped.
- Quickshell services available in 0.3.1: Pipewire, Mpris, SystemTray, UPower,
  Networking (NM only), Bluetooth (no authenticated pairing), Notifications, Pam,
  Greetd, Polkit, IdleMonitor, WlSessionLock, SystemClock, DesktopEntries, IpcHandler.

## Contracts and conventions

- QML config root is importable as `qs.*`: `import qs.modules.bar`, `import qs.config`,
  `import qs.services`. `Theme.qml` is a generated singleton (`Theme`) with the everforest
  palette and `fontFamily`.
- **Never hardcode colors or fonts in QML.** Use `Theme.*`. Add palette entries to
  `modules/lib/theme.nix` (single source of truth; every string attribute is picked up).
- Every layer surface gets its own `WlrLayershell.namespace` (`qs-shell-<surface>`);
  niri `layer-rule`s (blur, corner radius) live in `quickshell/default.nix` and match on
  the namespace. Add a rule only for surfaces that should blur. niri-flake merges sibling
  `_children` with the same name, so each repeated `layer-rule` needs its own `_children`
  parent.
- Multi-monitor: `Variants { model: Quickshell.screens }` for per-screen surfaces;
  popups target the focused output (`services/Niri`).
- Config name (`qs-shell`) appears in niri spawn commands, IPC calls
  (`quickshell -c qs-shell ipc call ...`) and layer-rule regexes. Renaming touches all.
- Quickshell gotchas: service singletons need `import Quickshell` even when importing
  e.g. `Quickshell.Services.Pipewire`; `WlrLayershell`/`WlrKeyboardFocus` need
  `import Quickshell.Wayland`; `property list<var>` deep-copies JS objects (breaks
  `indexOf(entry)`), use `property var`; initial service state loads fire property
  changes, so the OSD arms 1 s after startup.
- Style: nixfmt for Nix (`nix fmt`); conventional commits (`feat(quickshell): ...`);
  update `MEMORY.md` when a step lands.

## Build / test workflow

Flakes ignore untracked files: `git add` new files or Nix reports
`Path ... is not tracked by Git`.

No-switch dev loop (fast, no system activation):

```bash
out=$(nix build --no-link --print-out-paths --impure --expr \
  'let f = builtins.getFlake "/home/sean/nixos-config";
   in f.nixosConfigurations.notebook.config.home-manager.users.sean.xdg.configFile."quickshell/qs-shell".source')
quickshell --path "$out"          # run in foreground; Ctrl+C to stop
niri msg layers | grep qs-shell   # prove surfaces are mapped
```

Quickshell logs QML errors to stderr and saves a log; the startup line prints
`Saving logs to "/run/user/1000/quickshell/by-id/<id>/log.qslog"`. Stop the running
shell first (`pkill quickshell`) or you get two notification servers / two bars.

Apply workflow (build is the gate, switching is the user's call):

```bash
nh os build     # must be green before handing back
nh os switch
```

## Next steps (in rough order)

1. **Launcher**: content-sized overlay (see landmines), namespace `qs-shell-launcher`,
   then retire fuzzel.
2. **Control center** (Networking/Bluetooth/audio), optionally.
3. Optional lock polish: multi-monitor check of the per-output screenshots, a media/
   battery strip on the lock screen.

## Landmines

- **Do not import/copy caelestia code into `qs-shell`** (user's explicit wish). The
  vendored GPL-3.0 code lives only in git history (`cde3534`, deleted in `adc18af`).
- **Fullscreen transparent surfaces + niri blur** = the whole screen blurs (anyrun was
  reverted for this). Size surfaces to their content, or use
  `BackgroundEffect.blurRegion` (niri 26.04+).
- **Untracked files are invisible to Nix** - `git add` first (a new `qml/` directory
  that is not tracked makes the installed shell fail to start).
- Lock screens are security-critical: use a dedicated PAM service (not `login`), keep a
  fallback, and test the dead-locker path (niri keeps the session locked if the client
  dies, which is the safe direction, but verify reattach).
- Bluetooth in Quickshell 0.3.x: connect/disconnect is fine, **authenticated pairing is
  not**; keep `bluetui` for pairing.
- Don't switch/activate the system generation without being asked; `nh os build` is the
  expected gate.
- The whole-repo formatter is `nix fmt` (nixfmt-tree); for a single file use `nixfmt`.
