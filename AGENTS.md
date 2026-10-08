# Agents and contributors

Rules for this repo. Personal NixOS flake: one host (`notebook`), one user (`sean`), nixos-unstable + home-manager. One formatter, one way of doing each thing, self-contained feature modules. These rules are malleable: when the code is clearly better than a rule, change the rule.

## Layout

- `flake.nix` — inputs, `nixosConfigurations.notebook`, `formatter` (nixfmt-tree).
- `modules/notebook.nix` — NixOS host module: boot, hardware, locale, users, nix daemon, fonts. Imports the system-side features.
- `modules/sean.nix` — the `sean` user and the home-manager import list.
- `modules/features/<name>.nix` — one feature per file, or per directory when it ships assets or a dev guide (`niri/`, `quickshell/`). Small related features share a file (`extra-apps.nix`, `hardware-dev.nix`).
- `assets/` — static files referenced by features.

## Module rules

- A feature that only configures the user is a home-manager module, registered in `modules/sean.nix`.
- A feature that needs system options is a NixOS module imported by `modules/notebook.nix`, and attaches its user-level parts with `home-manager.sharedModules` (never `home-manager.users.<name>.imports`, which hardcodes the user). User config sits inline there; it moves to its own file next to the feature only when the feature is already a directory.
- One owner per option: a feature owns the packages, shell aliases, keybinds and generated files it declares. No second module may set the same option for the same purpose.
- Adding a feature = one file in `modules/features/` + one import line.

## Deliberate cross-module dependencies

- Features add their own niri entries from their own module (`quickshell/default.nix`: startup spawn and its binds). The rest of the niri binds live in `niri/keybindings.nix` and call tools owned by other features (`qs-shell` IPC for brightness, `fuzzel`, `foot`, `chromium-privat`).
- `lockscreen.nix` owns the `quickshell-lock` PAM service and the swaylock fallback for `quickshell`'s lock screen.
- `claude-code.nix`'s statusLine writes `$XDG_RUNTIME_DIR/claude-usage.json`, read by `quickshell/qml/services/ClaudeUsage.qml`; the contract is under Durable notes > Claude Code.
- `theme` (`features/theme.nix`) and `shadowDesktopEntries` (`features/desktop-entries.nix`) are home-manager `_module.args`, not available to NixOS modules.
- fish is split on purpose: `programs.fish.enable` and `users.users.sean.shell` live in `modules/sean.nix` (system side), the rest in `modules/features/shell.nix`.

## Style

- No comments in code (Nix, QML, embedded scripts). Reasoning belongs in the `.md` files: the Notes section of this file, or the feature's README next to it.
- All colours and the UI font come from `theme` (`features/theme.nix`); never inline a palette hex or a font family. Pure black (`#000000`) is not a palette colour.
- Take it as a module argument: `{ theme, ... }:`. API: `theme.<colour>` (bare hex: `bg0`..`bg4`, `grey0`..`grey2`, `fg`, `red`, `orange`, `yellow`, `green`, `aqua`, `blue`, `purple`), `theme.hex c` -> `"#a7c080"`, `theme.rgba c "44"` -> `"a7c08044"` (fuzzel's 8-digit form), `theme.rgb.<colour>` -> `[ 167 192 128 ]`, `theme.palette` (colours only), `theme.fontFamily`.
- `features/desktop-entries.nix` is the only place that builds `NoDisplay=true` desktop-entry shadows. Use `{ shadowDesktopEntries, pkgs, ... }:` then `xdg.dataFile = shadowDesktopEntries [ pkgs.libreoffice-stable ] [ "impress" ];`. Each feature shadows the entries of the packages it owns.

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
- **Dendritic pattern (flake-parts + import-tree)**: one host and one user, and every feature is already one file, so the migration (~25 files, two new inputs) buys no closure, speed or reuse gain. Revisit if a second host or user appears.
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
- Associations live with the app that owns them: `browser.nix` (web, images, pdf, json -> `chromium-privat`), `extra-apps.nix` (text and markdown -> Writer).
- Shadows use `NoDisplay=true`, never `Hidden=true`: `Hidden` removes the entry from the desktop database and broke audio/video launching via `mpv.desktop`. A shadowed entry stays available for MIME handling but hidden from launchers.

### Claude Code

- **Settings**: `~/.claude/settings.json` is also written by Claude Code (`/model`, `/config`), so `mutableSettings = true`: declared keys are merged in on activation and replace the existing value, other keys are left alone. Arrays are replaced, not merged. Removing a declaration does not remove the key; delete it by hand.
- **Subagents** run on Haiku (`CLAUDE_CODE_SUBAGENT_MODEL`) to stretch the Pro usage window.
- **MCP permissions**: home-manager ships MCP and LSP servers inside a generated plugin named `hm`, so tool names are `mcp__plugin_hm_<server>__<tool>`. `permissions.allow` needs one `mcp__plugin_hm_<server>` rule per `programs.mcp.servers` entry, or every call prompts.
- **Nix hook**: `claude-nix-hook` (PostToolUse on `Write|Edit|MultiEdit`) runs `nixfmt`, then `deadnix` and `statix` on the edited `.nix` file. Findings go to stderr with exit 2, which Claude Code feeds back to Claude, so unused arguments and bindings get fixed in the same turn. Non-Nix files and `nixfmt` failures (syntax error mid-edit) exit 0 silently.
- **nixd LSP** (`lspServers.nix`): gives Claude the `LSP` tool and passive diagnostics, including its own unused-definition warnings. Those arrive asynchronously and only for touched files, so the hook is the reliable check.
- **Usage file (contract with quickshell)**: the `statusLine` command gets session JSON on stdin. When it has `rate_limits.five_hour` (Pro/Max only, after the session's first API response), it writes `{"five_hour":{"used_percentage":23.5,"resets_at":1738425600},"seven_day":{...},"updated":1738420000}` atomically (`tmp` + `mv`) to `$XDG_RUNTIME_DIR/claude-usage.json`. `ClaudeUsage.qml` polls it; the bar shows `CC <n>%` (yellow, red from 90, grey `CC --` before the first session after boot, 0% once `resets_at` has passed). The file only updates while a session runs. If the field names change, fix the `jq` and `ClaudeUsage.qml` together.

### Browser

- Chromium has 4 profiles (Work-Admin, Work-Normal, School, Privat), each its own `--user-data-dir` (`~/.config/chromium-<key>`) with a `chromium-<key>` launcher. External extensions install per data dir, so this is the only declarative way to give Claude in Chrome to Privat alone. Privat is the default browser (`Mod+B`, MIME).
- Extensions come from the Web Store on first launch and are not removed if dropped from the config. uBlock Origin Lite replaces uBlock Origin (Chromium dropped MV2).
- Launchers pass `--password-store=basic`: autologin never hands PAM a password, so the gnome-keyring login keyring stays locked and Chromium would prompt on every launch. The Everforest theme is an unpacked extension loaded with `--load-extension`.
- If `claude --chrome` is used, its native-messaging host belongs in `~/.config/chromium-privat/NativeMessagingHosts`.

### Hardware

- **Hibernation**: `boot.resumeDevice = "/dev/mapper/cryptswap"`. Lid close locks while undocked (logind `lock` + swayidle `lock` event); docked lid close is ignored.
- **Serial and adb rules** (`hardware-dev.nix`): one generic ADB/Fastboot rule; serial rules for CP210x (10c4:ea60), CH340 (1a86:7523), FTDI (0403:6001) and ESP32-S3 native USB (303a:1001). If a phone is not detected, take its `vendor:product` from `lsusb` and add a rule.
- **Lock fallback**: `lockscreen.nix` runs the `qs-shell` lock through IPC and falls back to `swaylock -f` when no shell instance answers (the IPC call exits non-zero).

### Virtualisation

- `virtualisation.nix` uses the system connection `qemu:///system` (virt-manager autoconnects via dconf). libvirt's `default` NAT network (`default.xml`, copied into `/var/lib/libvirt` by `libvirtd-config`) is autostarted through a tmpfiles symlink in `networks/autostart/`, the file `virsh net-autostart` would create; libvirtd starts every network linked there when it starts. Disabling autostart with `virsh` only lasts until the next boot. OVMF (UEFI) ships with QEMU, so no `qemu.ovmf` option is set; `swtpm` gives guests a TPM (Windows 11).

### Other

- **fish**: command-not-found integration is disabled (slow); use `, tool` (comma + nix-index-database).
- **tealdeer**: `enableAutoUpdates = false` disables the systemd update service; `settings.updates.auto_update = true` makes tldr refresh itself. Both are intended.
- **License**: PolyForm Noncommercial 1.0.0. The vendored caelestia-shell code (GPL-3.0, `cde3534`, deleted in `adc18af`) stays in git history only; keep any future GPL-derived code under its own notice.
