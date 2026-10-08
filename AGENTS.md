# Agents and contributors

Rules for this repo. Personal NixOS flake: one host (`notebook`), one user (`sean`), nixos-unstable + home-manager, laid out in the dendritic pattern. One formatter, one way of doing each thing, self-contained feature modules. These rules are malleable: when the code is clearly better than a rule, change the rule.

## Layout

Every `.nix` file under `modules/` is a flake-parts module, loaded automatically by import-tree (paths containing `/_` are skipped). There is no import list to maintain.

- `flake.nix` — inputs and the flake-parts entry point: systems, `formatter` (nixfmt-tree), and the home-manager bridge (below). Nothing else.
- `modules/notebook.nix` — the host: `flake.nixosConfigurations.notebook`, the list of features it uses, and everything specific to this machine (hostname, platform, kernel modules, Intel graphics and microcode, thermald, disko layout, resume device, autologin, monitor layout, its RDP ethernet NIC, `stateVersion`).
- `modules/sean.nix` — the user: account, groups, login shell, home-manager integration, `home.stateVersion`.
- `modules/features/<name>.nix` — one feature per file. `quickshell/` is a directory because it ships QML and a dev guide; its Nix lives in `quickshell/default.nix`.
- `assets/` — static files referenced by features.

## Module rules

- A feature file defines `flake.modules.nixos.<name>`, `flake.modules.homeManager.<name>`, or both, under the same `<name>` as the file.
- The bridge in `flake.nix` turns every `homeManager.<name>` into `nixos.<name>` with `home-manager.sharedModules`, so a host only ever imports `nixos.<name>` and every user on that host gets the home-manager part. Never use `home-manager.users.<name>.imports` in a feature: that hardcodes the user.
- A host picks features by listing them in its `imports`, each exactly once (flake-parts modules carry no `key`, so a second import is not deduplicated). Leaving a feature out removes all of it: services, packages, binds, generated files.
- Machine-specific values belong in the host file, not in a feature. When a feature needs one (the RDP profile's NIC), the host sets that option itself.
- A feature owns everything it declares: packages, services, shell aliases, niri binds and window rules, generated files. A feature that adds niri binds spawns its tools by store path (`lib.getExe config.programs.foot.package`), so it keeps working on a host that leaves out the terminal or launcher feature.
- Adding a feature = one file in `modules/features/` + its name in each host that wants it. Adding a host = one file like `notebook.nix`.
- Inputs are captured from the enclosing flake-parts module (`{ inputs, ... }:` at the top of the file), never through `specialArgs`/`extraSpecialArgs`.

## Deliberate cross-module dependencies

- Features add their own niri entries (`audio`, `bluetooth`, `browser`, `clipboard`, `launcher`, `media`, `quickshell`, `shell`, `terminal`). `niri.nix` keeps only compositor settings and window-management binds. Setting niri options from a feature is harmless on a host without niri: the home-manager module exists, it is just not enabled.
- `niri.nix` starts the session from fish on tty1; the host provides the autologin.
- `quickshell` owns the `quickshell-lock` PAM service and the brightness keys (they drive its OSD). `lockscreen` owns swayidle and the swaylock fallback, so it works without `quickshell`.
- `claude-code`'s statusLine writes `$XDG_RUNTIME_DIR/claude-usage.json`, read by `quickshell/qml/services/ClaudeUsage.qml`; the contract is in `quickshell/README.md`.
- `editor`'s nixd reads options from `nixosConfigurations.<current hostname>` at the flake path from `nix`'s `programs.nh.flake`.
- fish is split on purpose: `programs.fish.enable` and the login shell live in `modules/sean.nix` (the user needs them), the rest in `features/shell.nix`.
- `hardware-dev`'s serial rules use the `dialout` group, which `sean.nix` grants.

## Style

- No comments in code (Nix, QML, embedded scripts). Reasoning belongs in the `.md` files: the Notes section of this file, or the feature's README next to it.
- All colours and the UI font come from `theme` (`features/theme.nix`); never inline a palette hex or a font family. Pure black (`#000000`) is not a palette colour.
- `theme` is a flake-parts module argument, so it reaches NixOS and home-manager modules alike: take it at the top of the file, `{ theme, ... }:`. API: `theme.<colour>` (bare hex: `bg0`..`bg4`, `grey0`..`grey2`, `fg`, `red`, `orange`, `yellow`, `green`, `aqua`, `blue`, `purple`), `theme.hex c` -> `"#a7c080"`, `theme.rgba c "44"` -> `"a7c08044"` (fuzzel's 8-digit form), `theme.rgb.<colour>` -> `[ 167 192 128 ]`, `theme.palette` (colours only), `theme.fontFamily`. The `theme` feature itself installs the fonts and sets GTK, icons and cursor.
- `features/desktop-entries.nix` is the only place that builds `NoDisplay=true` desktop-entry shadows. It is a helper, not a feature: take `{ shadowDesktopEntries, ... }:` at the top of the file, then `xdg.dataFile = shadowDesktopEntries pkgs pkgs.libreoffice-stable [ "impress" ];` inside the home-manager module. Each feature shadows the entries of the packages it owns.
- A feature that sets `xdg.mimeApps.defaultApplications` also sets `xdg.mimeApps.enable = true`.

## Commands

Run in the repo root.

- `nix fmt` — format (nixfmt-tree). `nix fmt -- --ci` to check only.
- `nix flake check` — quick test.
- `nix build .#nixosConfigurations.notebook.config.system.build.toplevel --dry-run` — deep evaluation test.
- `nix run nixpkgs#statix -- check .` and `nix run nixpkgs#deadnix -- .` — must report nothing.
- `nh os switch` / `nh os boot` — rebuild and apply now / on next boot.
- `rbu` — update flake inputs and commit `flake.lock`.
- `git add` new files before building: untracked files are invisible to flakes.

## Commits

Conventional Commits with the feature as scope: `feat(niri): ...`, `fix(quickshell): ...`, `docs`, `chore`, `cleanup`.

## Docs

`README.md` stays install-only. A feature's dev guide lives next to the feature (`modules/features/<name>/README.md`). The sections below the license hold only what git can't tell you: dismissed ideas, open questions, backlog and durable notes. No changelog entries; fold anything lasting into the code or a feature README.

## License

PolyForm Noncommercial 1.0.0 (see `LICENSE`). Contributions are accepted under the same license.

# Handoff

Nothing below is active work unless an entry says so.

## Dismissed ideas

- **Idle timeouts (auto lock/blank/suspend via swayidle)**: on purpose. Only the 5% hibernate safeguard and lid-close locking are wanted.
- **Avahi/mDNS for printer/scanner discovery**: printing works without it.
- **nixvim `inputs.nixpkgs.follows = "nixpkgs"`**: do not add. Upstream recommends against it; update nixvim and nixpkgs together.
- **Fingerprint reader (ELAN 04f3:0c4b)**: not supported by open-source libfprint; needs Lenovo's proprietary TOD blob.
- **Separate image for the niri overview backdrop**: niri has no native wallpaper support; it would need a second layer-shell client plus a `layer-rule`.
- **Animated launcher (anyrun)**: reverted. niri cannot animate layer surfaces, and anyrun's fullscreen transparent surface covered the screen under niri blur. Revisit only with a launcher that animates just its own box (planned in the Quickshell shell).
- **Trimming `linux-firmware` (about 800 MB)**: would break new hardware. Not worth it.
- **`services.udisks2` off**: loses USB automount.
- **Swapping deno for nodejs in mpv's yt-dlp (-138 MB)**: needs yt-dlp config and a local rebuild.
- **Deriving `XKB_DEFAULT_*` from `services.xserver.xkb`**: niri reads the environment variables, so they stay in `notebook.nix`.

## Open questions

- **`services.locate` (plocate)**: filename database so `locate foo` is instant. Needs a yes/no.

## Backlog

- **Shell**: atuin, direnv + nix-direnv, delta with git integration, television.
- **Nvim**: luasnip + blink-cmp snippet preset, optionally snacks.nvim; extra LSPs only if new file types appear.
- **Yazi**: plugin system (chmod, full-border, smart-enter).
- **Desktop apps**: password manager (keepassxc/bitwarden), localsend, nvtop, gdu/duf, zellij, kdeconnect; stylix to consolidate everforest theming.
- **Security**: Lanzaboote Secure Boot (firmware Secure Boot is off, test carefully); restic backups. TPM2 auto-unlock is blocked by firmware: enable Intel PTT in the BIOS first, then `boot.initrd.systemd.tpm2.enable` + `systemd-cryptenroll`.
- **ESP32**: platformio and/or arduino-language-server for nvim `.ino` support.
- **Gaming**: steam/proton, mangohud, gamemode if wanted.
- **Nvim LSP workers**: nixd spawns several eval workers per instance (about 1.2 GB across nvim and Claude Code); check nixd's worker setting if memory matters.

## Durable notes

### Fresh install and leftovers

- The password hash is a plain file placed at `/home/sean/.secrets/password.txt` (`hashedPasswordFile`), see `README.md`.
- Git uses HTTPS via `programs.gh`: run `gh auth login` once. No keyring is configured, so the token likely lands in plaintext `~/.config/gh/hosts.yml`. The `origin` remote must be HTTPS: `git remote set-url origin https://github.com/sean-imus/nixos-config.git`.
- sops was removed because nothing used it. Left on disk: `~/.sops`, `~/.config/sops-nix`.

### Rebuild speed and closure size

- `programs.nixvim.enableMan = false`: Home Manager's fish completion generator parses every man page, and nixvim's 7.3 MB `nixvim.5` cost 8.7 s per rebuild.
- `programs.fish.generateCompletions = false` (NixOS in `sean.nix`, HM in `shell.nix`): the generator parsed about 76 MB of man pages on every nixpkgs update. Completions come from carapace-bin plus vendor files. Re-add `programs.man.generateCaches = true` if `man -k` for home packages is missed.
- `services.speechd.enable = false`: `programs.niri` enables it through `graphical-desktop`, and it pulled in about 650 MB of mbrola voices.
- GC deletes generations older than 3 days; with 35 generations the store had grown to 46 GB. `nh clean all --keep 3` frees space immediately.
- nixd's flake path is the literal `/home/sean/nixos-config` (from `programs.nh.flake`), not `inputs.self`, so editing any tracked file does not rebuild nvim's init.lua.
- zram: `vm.swappiness = 180`, `vm.page-cluster = 0`. Revisit if disk swap ever gets hammered.

### MIME and desktop entries

- Archives are deliberately unhandled; extract via yazi/7zz.
- Associations live with the app that owns them: `browser.nix` (web, images, pdf, json -> `chromium-privat`), `office.nix` (text and markdown -> Writer).
- Shadows use `NoDisplay=true`, never `Hidden=true`: `Hidden` removes the entry from the desktop database and broke audio/video launching via `mpv.desktop`. A shadowed entry stays available for MIME handling but hidden from launchers.

### Browser

- Chromium has 4 profiles (Work-Admin, Work-Normal, School, Privat), each its own `--user-data-dir` (`~/.config/chromium-<key>`) with a `chromium-<key>` launcher. External extensions install per data dir, so this is the only declarative way to give Claude in Chrome to Privat alone. Privat is the default browser (`Mod+B`, MIME).
- Extensions come from the Web Store on first launch and are not removed if dropped from the config. uBlock Origin Lite replaces uBlock Origin (Chromium dropped MV2).
- Launchers pass `--password-store=basic`: autologin never hands PAM a password, so the gnome-keyring login keyring stays locked and Chromium would prompt on every launch. The Everforest theme is an unpacked extension loaded with `--load-extension`.
- If `claude --chrome` is used, its native-messaging host belongs in `~/.config/chromium-privat/NativeMessagingHosts`.

### Hardware

- **Hibernation**: `boot.resumeDevice = "/dev/mapper/cryptswap"`. Lid close locks while undocked (logind `lock` + swayidle `lock` event); docked lid close is ignored.
- **Serial and adb rules** (`hardware-dev.nix`): one generic ADB/Fastboot rule; serial rules for CP210x (10c4:ea60), CH340 (1a86:7523), FTDI (0403:6001) and ESP32-S3 native USB (303a:1001). If a phone is not detected, take its `vendor:product` from `lsusb` and add a rule.
- **Lock fallback**: `lockscreen.nix` runs the `qs-shell` lock through IPC and falls back to `swaylock -f` when no shell instance answers (the IPC call exits non-zero).

### Claude Code

- `~/.claude/settings.json` is also written by Claude Code (`/model`, `/config`), so `mutableSettings = true`: declared keys are merged in on activation and replace the existing value, every other key is left alone. Removing a declaration does not remove the key from the file; delete it by hand.
- Subagents run on Haiku (`CLAUDE_CODE_SUBAGENT_MODEL`) to stretch the Pro usage window. The format hook always exits 0, so a syntax error mid-edit never blocks Claude.

### Other

- **fish**: command-not-found integration is disabled (slow); use `, tool` (comma + nix-index-database).
- **tealdeer**: `enableAutoUpdates = false` disables the systemd update service; `settings.updates.auto_update = true` makes tldr refresh itself. Both are intended.
- **License**: PolyForm Noncommercial 1.0.0. The vendored caelestia-shell code (GPL-3.0, `cde3534`, deleted in `adc18af`) stays in git history only; keep any future GPL-derived code under its own notice.
