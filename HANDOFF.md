# Handoff

What git history can't tell you: dismissed ideas and why, open questions, the backlog and durable notes. No changelog entries, `git log` has those. Nothing here is active work unless an entry says so.

## Dismissed

- **Idle timeouts (auto lock/blank/suspend via swayidle)**: on purpose. Only the 5% hibernate safeguard and lid-close locking are wanted.
- **Avahi/mDNS for printer/scanner discovery**: printing works without it; Avahi only adds automatic discovery.
- **nixvim `inputs.nixpkgs.follows = "nixpkgs"`**: do not add. Upstream recommends against it; update nixvim and nixpkgs together.
- **Fingerprint reader (ELAN 04f3:0c4b)**: not viable. Not supported by open-source libfprint; needs Lenovo's proprietary TOD blob.
- **Separate image for the niri overview backdrop**: niri has no native wallpaper support, so it would need a second layer-shell client (`awww-daemon --namespace backdrop` + `awww img` + a `layer-rule`). Too much machinery for one wallpaper.
- **Animated launcher (anyrun)**: tried and reverted. niri cannot animate layer surfaces, and anyrun's fullscreen transparent surface covered the whole screen under niri blur. Revisit only with a launcher that animates just its own box (planned in the Quickshell shell).
- **Dendritic pattern (flake-parts + import-tree)**: skipped. One host and one user, and every feature is already one file, so the migration (~25 files, two new inputs) buys no closure, speed or reuse gain. Revisit if a second host or user appears.
- **`Mod+U` background rebuild (`rebuild.nix`)**: removed. Use `nh os switch` / `nh os boot`.

## Open questions

- **`services.locate` (plocate)**: filename database so `locate foo` is instant. Runs a low-priority `updatedb` timer; off by default in NixOS. Needs a yes/no.

## Backlog

- **Shell**: atuin, direnv + nix-direnv, delta with git integration, `programs.bat`, television.
- **Nvim**: luasnip + blink-cmp snippet preset, optionally snacks.nvim; extra LSPs only if new file types appear (taplo/yamlls/jsonls/bashls/fish_lsp).
- **Yazi**: plugin system (chmod, full-border, smart-enter).
- **Desktop apps**: password manager (keepassxc/bitwarden) since the browser's built-in one is not used; localsend; nvtop; gdu/duf; zellij; kdeconnect; stylix to consolidate everforest theming (niri itself is not a stylix target).
- **Security**: Lanzaboote Secure Boot (works with systemd-boot; firmware Secure Boot is currently off, test carefully); restic backups (none yet). TPM2 auto-unlock is blocked by firmware (`bootctl` reports "TPM2 Support: no"): enable Intel PTT in the BIOS first, then `boot.initrd.systemd.tpm2.enable` + `systemd-cryptenroll`.
- **ESP32**: platformio and/or arduino-language-server for nvim `.ino` support.
- **Gaming**: steam/proton, mangohud, gamemode if wanted.
- **Quickshell shell**: launcher, control center, lock polish. See `modules/features/quickshell/README.md`.

## Notes

### License

PolyForm Noncommercial 1.0.0 (root `LICENSE`, verbatim). Goal: anyone may use, modify and redistribute for noncommercial purposes, nobody may sell it. Chosen over CC BY-NC because it is written for software (explicit patent grant, distribution terms). History: GPL-3.0-or-later on 2026-09-17, briefly CC BY-NC 4.0.

- Source-available, not open source by OSI/FSF definitions.
- Commits before the change stay GPL-3.0 for anyone who already has them. The vendored caelestia-shell code (`cde3534`, GPL-3.0, deleted in `adc18af`) remains GPL in history; the current `quickshell/qml` is from scratch. If GPL-derived code ever lands again, keep its notice and license it accordingly.

### Fresh install and leftovers

- The password hash is a plain file placed at `/home/sean/.secrets/password.txt` (`hashedPasswordFile`), see `README.md`.
- Git uses HTTPS via `programs.gh`: run `gh auth login` once (HTTPS, browser/device flow). No keyring is configured, so the token likely lands in plaintext `~/.config/gh/hosts.yml`. The `origin` remote must be HTTPS: `git remote set-url origin https://github.com/sean-imus/nixos-config.git`.
- sops (`sops-nix` input, `secrets/` module) was removed because nothing used it. To bring secrets back, re-add the input and a `secrets/` module.
- Left on disk: `~/.sops` (age key, stale `ssh_key` symlink), `~/.config/sops-nix`.

### Rebuild speed

The `why` behind several small options:

- `programs.nixvim.enableMan = false`: Home Manager's fish completion generator parses every package's man pages, and nixvim's 7.3 MB `nixvim.5` took 8.7 s per rebuild for 4 junk completion lines. `man nixvim` is gone; use nixd hover or the online docs.
- `programs.fish.generateCompletions = false` (NixOS in `modules/sean.nix`, HM in `modules/features/shell.nix`): the generator parsed ~59 MB (system) and ~17 MB (HM) of man pages on every nixpkgs update. Also dropped: HM `man-paths`/`man-cache`, `manual.manpages.enable`, `programs.nixvim.enablePrintInit`. Completions come from carapace-bin plus package vendor files. Re-add `programs.man.generateCaches = true` if `man -k`/`apropos` for home packages is missed.
- zram: `vm.swappiness = 180`, `vm.page-cluster = 0`. Revisit if disk swap ever gets hammered.

### MIME and desktop entries

- Archives (`zip`/`tar`/`7z`/`rar`/...) are deliberately unhandled; extract via yazi/7zz.
- Presentations: `impress.desktop` is shadowed with a `NoDisplay=true` copy, so associations work and the launcher stays clean.
- `text/markdown` and `text/x-markdown` -> Writer; `application/json` -> Chromium Privat (built-in viewer).
- All shadows use `NoDisplay=true`, never `Hidden=true`: `Hidden` shadows broke audio/video launching via `mpv.desktop`.

### Browser

- Chromium has 4 profiles (Work-Admin, Work-Normal, School, Privat), each its own `--user-data-dir` (`~/.config/chromium-<key>`) with a `chromium-<key>` launcher. External extensions install per data dir, so this is the only declarative way to give Claude in Chrome to Privat alone. Privat is the default browser (`Mod+B`, MIME, http/https).
- uBlock Origin Lite replaces uBlock Origin (Chromium dropped MV2). Extensions are installed from the Web Store on first launch and are not removed if dropped from the config.
- Launchers pass `--password-store=basic`: autologin leaves the gnome-keyring login keyring locked, and Chromium would prompt for it on every launch.
- If `claude --chrome` is used, its native-messaging host belongs in `~/.config/chromium-privat/NativeMessagingHosts`.

### Other

- **Hibernation**: resume via `boot.resumeDevice = "/dev/mapper/cryptswap"`. Lid close locks while undocked (logind `lock` + swayidle `lock` event); docked lid close is ignored.
- **adb**: a generic ADB/Fastboot udev rule exists. If a phone is still not detected, take its `vendor:product` from `lsusb` and add a vendor-specific rule to `modules/features/android.nix`.
- **fish**: command-not-found integration is disabled (slow); use `, tool` (comma + nix-index-database). `rbu` updates flake inputs and commits `flake.lock` (nh cannot do that).
