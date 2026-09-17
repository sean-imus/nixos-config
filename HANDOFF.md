# HANDOFF: personal Quickshell shell (`qs-shell`)

Audience: a fresh agent picking up this work with no prior context. Read this file,
then `MEMORY.md` (decision log) and `AGENTS.md` (repo working agreements).

## Goal

This repo is a NixOS + Home Manager flake for a niri laptop ("notebook"), themed with
everforest. The task: replace the remaining desktop-shell components (waybar, fuzzel,
swaylock, ...) with a **personal, from-scratch Quickshell config**. It is deliberately
*not* derived from caelestia-shell, unlike the older notifications module. Write clean
own QML; do not copy caelestia QML into the new shell.

## Current state (commit 23e00c7, 2026-09-16)

Implemented and installed:

- `modules/features/quickshell/` = HM config `qs-shell`:
  - `default.nix`: copies `qml/` into a store derivation and generates
    `config/Theme.qml` from `modules/lib/theme.nix` (same pattern as notifications).
  - `qml/shell.qml`: `ShellRoot` + `Variants { model: Quickshell.screens }` → one
    `Bar` per screen.
  - `qml/modules/bar/Bar.qml`: bottom 18px transparent `PanelWindow`, clock left
    (`SystemClock`, "HH:mm dd.MM.yyyy"), `WlrLayer.Top`, namespace `qs-shell-bar`,
    `exclusiveZone: 18` (waybar geometry).
- Wired into Home Manager in `modules/sean.nix` (import `./features/quickshell`).
- Installed at `~/.config/quickshell/qs-shell`; **not spawned at startup** and not
  currently running.
- Waybar (`modules/features/bar.nix`) is still the active bar. caelestia-notifs still
  owns `org.freedesktop.Notifications` and runs as `quickshell -c caelestia-notifs -n`.

Verified this session:

- `quickshell --path <config-store-dir>` → `Configuration Loaded`, no QML errors.
- `niri msg layers` → two `qs-shell-bar` surfaces (one per monitor).
- `nh os build` → green (+6.28 KiB).

Environment facts (verified, do not re-research):

- Quickshell **0.3.1** is in the pinned nixpkgs; niri **26.04**.
- niri supports ext-session-lock, ext-workspace (25.11+), ext-idle-notify,
  ext-background-effect blur (26.04+).
- Quickshell has **no native niri module**. Use `niri msg` / the niri IPC socket.
  Do not copy Hyprland-based examples from upstream docs.
- niri's window JSON has **no `is_fullscreen` field** (checked live 2026-09-16);
  fullscreen suppression must be approximated (tile_size vs output size) or skipped.
- Quickshell services available in 0.3.1: Pipewire, Mpris, SystemTray, UPower,
  Networking (NM only), Bluetooth (no authenticated pairing), Notifications, Pam,
  Greetd, Polkit, IdleMonitor, WlSessionLock, SystemClock, DesktopEntries, IpcHandler.

## Contracts and conventions

- QML config root is importable as `qs.*`: `import qs.modules.bar`, `import qs.config`.
  `Theme.qml` is a singleton (`Theme`) with the everforest palette (`bg0..bg4`,
  `grey0..grey2`, `fg`, `red/orange/yellow/green/aqua/blue/purple`) and `fontFamily`.
- **Never hardcode colors or fonts in QML.** Use `Theme.*`. Add new palette entries to
  `modules/lib/theme.nix` (single source of truth; the generated `Theme.qml` picks up
  every string attribute automatically).
- Every layer surface gets its own `WlrLayershell.namespace` (`qs-shell-<surface>`);
  niri `layer-rule`s (blur, corner radius) match on the namespace. Add a rule only for
  surfaces that should blur.
- Multi-monitor: `Variants { model: Quickshell.screens }` with
  `required property ShellScreen modelData`. Popups should target the focused output.
- Config name (`qs-shell`) appears in niri spawn commands, IPC calls
  (`quickshell -c qs-shell ipc call ...`) and layer-rule regexes. Renaming touches
  all of them.
- Style: nixfmt for Nix; conventional commits (`feat(quickshell): ...`); update
  `MEMORY.md` when a step lands. Confirm before changing anything caelestia-notifs
  related (see landmines).

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
`Saving logs to "/run/user/1000/quickshell/by-id/<id>/log.qslog"`.

Apply workflow (build is the gate, switching is the user's call):

```bash
nh os build     # must be green before handing back
nh os switch    # or Mod+U (builds in background, applies with one run0 prompt)
```

Then `quickshell -c qs-shell` runs the installed config; optionally `pkill waybar`
first (running both bars reserves 36px at the bottom).

## Next step (recommended): niri event-stream service

Add `qml/services/Niri.qml` as a `Singleton` (`pragma Singleton`) exposing niri state
to the bar:

- `Process { command: ["niri", "msg", "event-stream"]; running: true }` with a
  `SplitParser` on stdout; each line is JSON, parse with `JSON.parse`.
- niri emits initial state as events when the stream opens (`WorkspacesChanged`,
  `WindowsChanged`, `OutputsChanged`, `KeyboardLayoutsChanged`), so no separate query
  is needed.
- Handle at least: `WorkspacesChanged`, `WorkspaceActivated`,
  `WorkspaceUrgencyChanged`, `WindowFocusChanged`, `OverviewOpenedOrClosed`,
  `KeyboardLayoutsChanged`, `OutputsChanged`.
- Track: `workspaces` (`{id, idx, name, output, is_urgent, is_active, is_focused,
  active_window_id}`), `focusedOutput`, `activeWindow` (`title`, `app_id`),
  `overviewOpen`. Restart the process via `onExited` if the stream dies.
- Wire into `Bar.qml`: show workspace indices (focused vs active vs urgent using
  `Theme.fg` / `Theme.grey0` / `Theme.red`), optionally the active window title.
- Reference for niri JSON shapes: `niri msg --json workspaces`,
  `niri msg --json focused-window`. The old notifications config has
  `qml/services/Niri.qml`, but it only polls `focused-output` every second - do better.

Acceptance: focusing/moving workspaces or windows updates the bar immediately, no
polling, quickshell log clean, `nh os build` green.

## Later steps (in rough order)

1. **Waybar parity widgets**: battery (`UPower.displayDevice`), volume + mic
   (`Pipewire.defaultAudioSink`/`.defaultAudioSource`), power profile
   (`PowerProfiles`), click/scroll actions. Then remove waybar: swap the niri
   `spawn-at-startup` to `quickshell -c qs-shell -n` and delete `features/bar.nix`.
2. **OSD** for volume/brightness on state changes (brightness has no Quickshell
   service; use `brightnessctl`/sysfs).
3. **Notification center + own notification server**, then retire caelestia-notifs:
   remove its spawn, layer-rule, `Mod+Shift+D`/`Mod+Shift+N` binds
   (`modules/features/notifications/default.nix`) and the module itself.
4. **Lock screen**: `WlSessionLock` + `PamContext` with a dedicated
   `security.pam.services.quickshell-lock`; keep swaylock installed as fallback;
   point swayidle's `lock` event at `quickshell -c qs-shell ipc call lock lock`.
5. **Launcher** (content-sized overlay, see landmines), **control center**
   (Networking/Bluetooth/audio), optionally a **polkit agent**
   (`Quickshell.Services.Polkit`).

## Landmines

- **Do not import/copy caelestia code into `qs-shell`** (user's explicit wish). The old
  module is GPL-3.0 and stays as-is until replaced. It is the live notification daemon:
  don't kill or reconfigure it while working on unrelated surfaces.
- **Fullscreen transparent surfaces + niri blur** = the whole screen blurs (anyrun was
  reverted for this). Size surfaces to their content, or use
  `BackgroundEffect.blurRegion` (niri 26.04+).
- **Untracked files are invisible to Nix** - `git add` first.
- Two bars at once reserve 36px at the bottom; kill waybar when testing.
- Lock screens are security-critical: use a dedicated PAM service (not `login`), keep a
  fallback, and test the dead-locker path (niri keeps the session locked if the client
  dies - safe direction, but verify reattach).
- Bluetooth in Quickshell 0.3.x: connect/disconnect is fine, **authenticated pairing is
  not**; keep `bluetui` for pairing.
- Don't switch/activate the system generation without being asked; `nh os build` is the
  expected gate.
- The whole-repo formatter is `nix fmt` (nixfmt-tree); for a single file use `nixfmt`.

## Verification log (previous session)

- `quickshell --path /nix/store/...-qs-shell-qml` → `Configuration Loaded`, no errors.
- `niri msg layers` → 2 × `Namespace: "qs-shell-bar"`.
- `nh os build` → `✔ nixos-system-notebook-...`, ADDED `qs-shell-qml`, +6.28 KiB.
- Committed as `23e00c7 feat(quickshell): add a personal Quickshell shell with a clock bar`.
