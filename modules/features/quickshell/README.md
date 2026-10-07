# qs-shell

A personal, from-scratch Quickshell config for the niri laptop (`notebook`, everforest theme). One process replaces the usual desktop-shell parts. It is deliberately *not* derived from caelestia-shell: write clean own QML and never copy caelestia QML into it.

Installed as the Home Manager config `qs-shell` (`programs.quickshell.configs.qs-shell`) and spawned at niri startup as `quickshell -c qs-shell -n` (`default.nix`). Repo rules are in `CONTRIBUTING.md`; parked and dismissed ideas are in `DECISIONS.md`.

## What it owns

- **Bar** (`qml/modules/bar/Bar.qml`): bottom 18px, one per screen. Clock, niri workspaces (`services/Niri.qml`, event-stream driven), battery/volume/mic/power profile with click/scroll actions.
- **Notifications** (`services/Notifs.qml`, `modules/notifs/NotifPopups.qml`): own `org.freedesktop.Notifications` server, in-memory only. Cards are translucent with an app-initial badge, accent stripe and countdown line. DND/clear via IPC (`notifs toggleDnd|clear`, niri binds `Mod+Shift+D` / `Mod+Shift+N`).
- **Polkit agent** (`modules/polkit/PolkitDialog.qml`, `services/Polkit.qml`): uses polkit's own session/helper and the stock `polkit-1` PAM. If the shell dies, elevation prompts wedge until it is restarted.
- **OSD** (`modules/osd/OsdPanel.qml`, `services/Osd.qml`, `Audio.qml`, `Brightness.qml`): volume/mic/brightness/power profile. Brightness is a sysfs poll (no inotify on sysfs): 500 ms idle, 25 ms for 1.2 s after the brightness keys call `ipc call brightness poke`.
- **Lock** (`services/Lock.qml`, `components/SecretDots.qml`): `WlSessionLock` + PAM service `quickshell-lock` (declared in `modules/notebook.nix`), IPC target `lock`. Wired to `Super+Alt+L` and swayidle's `lock` event, with a swaylock fallback in `lockscreen.nix`. The background is a blurred per-output `grim` screenshot taken *before* the lock engages. `SecretDots` is also used by the polkit dialog.
- **IPC**: `powerprofiles cycle` (`Mod+P`), `notifs ...`, `lock lock`, `brightness poke`. `Mod+Shift+R` restarts the whole shell (script in `default.nix`, log `~/.cache/qs-shell-restart.log`).

Retired: waybar, caelestia-notifs, soteria. The launcher is still **fuzzel** (`features/launcher.nix`, `Mod+Space`).

## Environment facts

- Quickshell **0.3.1** in the pinned nixpkgs; niri **26.04** (ext-session-lock, ext-workspace, ext-idle-notify, ext-background-effect blur).
- Quickshell has **no native niri module**. Use `niri msg` / the event stream; do not copy Hyprland-based examples from upstream docs.
- niri's window JSON has **no `is_fullscreen`**: fullscreen suppression must be approximated or skipped.
- Available services: Pipewire, Mpris, SystemTray, UPower, Networking (NM only), Bluetooth (no authenticated pairing), Notifications, Pam, Greetd, Polkit, IdleMonitor, WlSessionLock, SystemClock, DesktopEntries, IpcHandler.

## Conventions

- The QML root is importable as `qs.*` (`import qs.modules.bar`, `import qs.config`, `import qs.services`). `Theme.qml` is a generated singleton with the everforest palette and `fontFamily`.
- **Never hardcode colours or fonts in QML.** Use `Theme.*`; add palette entries to `modules/lib/theme.nix` (every string attribute is picked up).
- Every layer surface gets its own `WlrLayershell.namespace` (`qs-shell-<surface>`). niri `layer-rule`s (blur, corner radius) live in `default.nix` and match the namespace; add one only for surfaces that should blur. niri-flake merges sibling `_children` with the same name, so each repeated `layer-rule` needs its own `_children` parent.
- Multi-monitor: `Variants { model: Quickshell.screens }` for per-screen surfaces; popups target the focused output (`services/Niri`).
- The config name `qs-shell` appears in niri spawn commands, IPC calls (`quickshell -c qs-shell ipc call ...`) and layer-rule regexes. Renaming touches all of them.
- Commits: `feat(quickshell): ...`. Format Nix with `nix fmt`.

## Gotchas

- Service singletons need `import Quickshell` even when importing e.g. `Quickshell.Services.Pipewire`; `WlrLayershell` / `WlrKeyboardFocus` need `import Quickshell.Wayland`.
- `property list<var>` deep-copies JS objects (breaks `indexOf(entry)`): use `property var`.
- Initial service state loads (Pipewire connect, sysfs poll, PowerProfiles init) fire property changes, so the OSD arms 1 s after startup.
- An integer `model` rebuilds every delegate when the count changes: use a `ListModel`. A plain array model replays every card's animation when an item is added: use `ScriptModel` over QtObjects with a `leaving` state.
- `NotificationAction` has `text`, not `label`.
- `WlSessionLock.locked` notifies through `lockStateChanged` (there is no `lockedChanged`) and only fires once the compositor confirms the lock, so PAM and test timers start from `lock()` itself. `unlock()` is not callable from QML: set `locked = false`.
- A niri `layer-rule` blur covers the whole layer surface, which shows as a halo when a card animates inside a larger window. A client-side `BackgroundEffect.blurRegion` did not fix it in practice, so polkit and notification cards are opaque with no blur rules.
- The polkit flow goes null instantly on exit: freeze its text with `Binding { when: wanted }` so the exit animation keeps its content, and make the window taller than the card so motion is not clipped.
- `pkill -f` matches any command line containing the pattern. swayidle's command line contains `quickshell -c qs-shell ipc call lock lock`, so the restart script anchors its pattern to the start of the command line. The wrapped process name is `.quickshell-wrapped`; `setsid` is in util-linux, not coreutils.
- **Untracked files are invisible to Nix.** `git add` new files; a new untracked `qml/` directory makes the installed shell fail with `module "qs.components" is not installed`.

## Build and test

No-switch dev loop (no system activation):

```bash
out=$(nix build --no-link --print-out-paths --impure --expr \
  'let f = builtins.getFlake "/home/sean/nixos-config";
   in f.nixosConfigurations.notebook.config.home-manager.users.sean.xdg.configFile."quickshell/qs-shell".source')
quickshell --path "$out"          # foreground; Ctrl+C to stop
niri msg layers | grep qs-shell   # prove surfaces are mapped
```

Quickshell logs QML errors to stderr and prints `Saving logs to "/run/user/1000/quickshell/by-id/<id>/log.qslog"`. Stop the running shell first (`pkill quickshell`) or you get two notification servers and two bars.

Apply: `nh os build` must be green before handing back; `nh os switch` is the user's call.

Lock dev switches (inert unless set): `QS_LOCK_TEST=1` auto-unlocks after 30 s, `QS_LOCK_CLOCK=seconds` ticks the clock and date every second. Safe lock test: log in on a second TTY, run the shell with `QS_LOCK_TEST=1`, and recover with `pkill quickshell` then `WAYLAND_DISPLAY=wayland-1 swaylock`.

## Landmines

- **Do not import or copy caelestia code.** The vendored GPL-3.0 code lives only in git history (`cde3534`, deleted in `adc18af`).
- **Fullscreen transparent surfaces + niri blur** = the whole screen blurs (anyrun was reverted for this). Size surfaces to their content.
- Lock screens are security-critical: dedicated PAM service (not `login`), keep a fallback, and test the dead-locker path (niri keeps the session locked if the client dies, the safe direction, but verify reattach).
- Bluetooth in Quickshell 0.3.x: connect/disconnect works, **authenticated pairing does not**; keep `bluetui` for pairing.
- Do not switch/activate the system generation unless asked.

## Roadmap

1. **Launcher**: content-sized overlay, namespace `qs-shell-launcher`, then retire fuzzel.
2. **Control center** (Networking/Bluetooth/audio), optionally.
3. Lock polish: multi-monitor check of the per-output screenshots, a media/battery strip.

Known trade-off: the lock's colon pulse keeps the lock surface redrawing while locked.
