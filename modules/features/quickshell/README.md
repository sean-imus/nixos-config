# qs-shell

A personal, from-scratch Quickshell config for the niri laptop (`notebook`, everforest theme). One process replaces the usual desktop-shell parts. It is deliberately *not* derived from caelestia-shell: write clean own QML and never copy caelestia QML into it.

Installed as the Home Manager config `qs-shell` (`programs.quickshell.configs.qs-shell`) and spawned at niri startup as `quickshell -c qs-shell -n` (`default.nix`). Repo rules are in `AGENTS.md`; parked and dismissed ideas are in the Handoff section of `AGENTS.md`.

## What it owns

- **Bar** (`qml/modules/bar/Bar.qml`): bottom 18px, one per screen. Clock, niri workspaces (`services/Niri.qml`, event-stream driven), Claude plan usage `CC <n>%` (`services/ClaudeUsage.qml`, polls `$XDG_RUNTIME_DIR/claude-usage.json` written by the Claude Code statusLine; contract in `AGENTS.md` under Durable notes > Claude Code), battery/volume/mic/power profile with click/scroll actions.
- **Notifications** (`services/Notifs.qml`, `modules/notifs/NotifPopups.qml`): own `org.freedesktop.Notifications` server, in-memory only. Cards are translucent with an app-initial badge, accent stripe and countdown line. DND/clear via IPC (`notifs toggleDnd|clear`, niri binds `Mod+Shift+D` / `Mod+Shift+N`).
- **Polkit agent** (`modules/polkit/PolkitDialog.qml`, `services/Polkit.qml`): uses polkit's own session/helper and the stock `polkit-1` PAM. If the shell dies, elevation prompts wedge until it is restarted.
- **OSD** (`modules/osd/OsdPanel.qml`, `services/Osd.qml`, `Audio.qml`, `Brightness.qml`): volume/mic/brightness/power profile. Brightness is read from sysfs (inotify is unreliable there) and only polled, every 25 ms for 1.2 s, after the brightness keys call `ipc call brightness poke`; external brightness changes do not show the OSD. The bar clock ticks per minute; `ClaudeUsage` polls every 30 s.
- **Lock** (`services/Lock.qml`, `components/SecretDots.qml`): `WlSessionLock` + PAM service `quickshell-lock` (declared in `lockscreen.nix`), IPC target `lock`. Wired to `Super+Alt+L` (bind in `default.nix`) and swayidle's `lock` event, with a swaylock fallback, both in `lockscreen.nix`. If the shell dies while locked, run `swaylock` from a TTY. The background is a blurred per-output `grim` screenshot taken *before* the lock engages. `SecretDots` is also used by the polkit dialog.
- **IPC**: `powerprofiles cycle` (`Mod+P`), `notifs ...`, `lock lock`, `brightness poke`. `Mod+Shift+R` restarts the whole shell (script in `default.nix`, log `~/.cache/qs-shell-restart.log`; it toasts "Shell restarted" once the new instance answers IPC and gives up early if the process dies during startup). `grim` and `libnotify` are installed for the lock screenshots and that toast; the generated `Theme.qml` also declares `symbolFont` (Symbols Nerd Font Mono, from `nerd-fonts.symbols-only` in `notebook.nix`).

The launcher is still **fuzzel** (`features/launcher.nix`, `Mod+Space`).

## Environment facts

- Quickshell **0.3.1** in the pinned nixpkgs; niri **26.04** (ext-session-lock, ext-workspace, ext-idle-notify, ext-background-effect blur).
- Quickshell has **no native niri module**. Use `niri msg` / the event stream; do not copy Hyprland-based examples from upstream docs.
- niri's window JSON has **no `is_fullscreen`**: fullscreen suppression must be approximated or skipped.
- Available services: Pipewire, Mpris, SystemTray, UPower, Networking (NM only), Bluetooth (no authenticated pairing), Notifications, Pam, Greetd, Polkit, IdleMonitor, WlSessionLock, SystemClock, DesktopEntries, IpcHandler.

## Conventions

- The QML root is importable as `qs.*` (`import qs.modules.bar`, `import qs.config`, `import qs.services`). `Theme.qml` is a generated singleton with the everforest palette and `fontFamily`.
- **Never hardcode colours or fonts in QML.** Use `Theme.*`; add palette entries to `modules/features/theme.nix` (every entry of `theme.palette` is picked up).
- Every layer surface gets its own `WlrLayershell.namespace` (`qs-shell-<surface>`). No niri `layer-rule`s exist today (see below). To add one, put it in `default.nix`, match the namespace, and give each repeated `layer-rule` its own `_children` parent (Home Manager's niri module merges siblings with the same name).
- Multi-monitor: `Variants { model: Quickshell.screens }` for per-screen surfaces; popups target the focused output (`services/Niri`).
- The config name `qs-shell` appears in niri spawn commands, IPC calls (`quickshell -c qs-shell ipc call ...`) and any future layer-rule regexes. Renaming touches all of them.
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

## Design notes

The QML carries no comments; the reasoning lives here.

- **Niri service**: one long-lived `niri msg -j event-stream`; only `Workspace*` events are parsed. State is replaced whole on each event so readonly bindings re-evaluate. Window, overview and keyboard-layout events are deliberately not tracked: nothing reads them (re-add when something does).
- **Audio**: `Pipewire.defaultAudioSink` is briefly undefined during default-metadata updates and untracked nodes have no audio data, so every access is exception-safe (one throw kills the binding for good). A tracker follows the default nodes when they change.
- **ClaudeUsage**: the file is replaced by rename, which inotify watches miss, so it is polled. It only refreshes while a Claude Code session runs; a window whose `resets_at` has passed counts as 0, a missing file as -1 (`CC --`). A parse failure keeps the previous value (the file may be mid-write); `printErrors: false` because the file is absent until the first session after boot.
- **Power**: `services/Power.qml` owns the profile cycle order and the label/colour/icon used by the bar, the OSD and the `powerprofiles cycle` IPC. Performance without `hasPerformanceProfile` counts as medium.
- **Osd**: `armed` flips 1 s after start so initial loads (Pipewire connect, first sysfs read, power-profiles init) never flash it. Progress is 0..1, or -1 when the kind has no bar (profile, muted). `OsdPanel` keeps showing the last content while the exit plays because `Osd.clear()` empties the state at once. The surface is larger than the pill so spring overshoot and exit drift are not clipped, and it never takes pointer input.
- **Notifs**: critical notifications without a timeout stay until dismissed; others get 6 s. Entries are `QtObject`s so cards can react to `leaving`, and `ScriptModel` keeps delegate identity so a new notification does not replay other cards' animations. Under DND notifications are accepted but never shown and expire quickly. Leaving entries play the exit animation, then the list drops them.
- **Polkit dialog**: an unanchored layer-shell surface is centred on both axes, which keeps the window content-sized. The flow becomes null the instant a request ends; the card freezes its copies of the flow text so it keeps its content through the exit. The keyboard is released as soon as the request ends. After a failed attempt the flow stays alive with a fresh session: shake, flag the error, clear the stale password, keep the dialog open. The dots stay on screen (dimmed) until PAM answers. The text field hides its caret for hidden input and only takes keys; `SecretDots` draws the symbols.
- **SecretDots**: every typed character is a dot; the newest first springs in as a big random symbol (Nerd Font Font Awesome glyphs from `Theme.symbolFont`, palette colours), holds a beat, then morphs into a small dot. Typing the next character fast-forwards the previous one. Symbols are a pure function of (index, salt, tick), so instances with the same salt (one per monitor) agree. The model is a real `ListModel` and the strip shrinks instead of overflowing on long passwords.
- **Lock**: `WlSessionLock` with PAM service `quickshell-lock`. Each output is grabbed with `grim` before the lock surface covers it (screencopy would only see the lock afterwards); the background is that screenshot decoded at a tiny size (most of the blur) plus a `MultiEffect` to remove blockiness, tinted towards the palette. Screenshots are loaded synchronously and deleted from the runtime dir right after; the lock is never delayed for long if `grim` is slow or missing. Key input is raw key capture instead of a `TextField`, so there are no enabled/focus states to desync from PAM. All outputs share state (pending, failed, shake, salt, show/hide progress); each element derives a staggered slice from the progress. Clock digits fly in from their own edge and roll on change; the colon breathes once settled; the date letters swarm in on a golden-angle spread. The dots stay until PAM answers, otherwise they shrink and drift while the pill is already animating away.

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
