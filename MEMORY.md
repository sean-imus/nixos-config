# MEMORY

Decision log for parked ideas, open questions and the backlog. Nothing here is active work unless an entry says so.

Parked ideas and decisions from the config deep dive (2026-09-15). Only the items marked "done" were applied.

## Dismissed for now

- **Idle timeouts (auto lock/blank/suspend via swayidle)**: dismissed on purpose. Only the 5% hibernate safeguard and lid-close locking are wanted.
- **Avahi/mDNS for printer/scanner discovery**: dismissed. Printing worked without it; Avahi only adds automatic discovery, not functionality.
- **nixvim `inputs.nixpkgs.follows = "nixpkgs"`**: do not add. Upstream nixvim explicitly recommends against it; update nixvim and nixpkgs together instead.
- **Fingerprint reader (ELAN 04f3:0c4b)**: not viable. Not supported by open-source libfprint; requires Lenovo's proprietary TOD blob.
- **Separate image for the niri overview backdrop**: dismissed. niri has no native wallpaper support, so a backdrop image needs a second layer-shell client with its own namespace (`awww-daemon --namespace backdrop` + `awww img` + a `layer-rule`); too much machinery for one wallpaper.
- **Animated launcher (anyrun)**: tried and reverted. Fuzzel has no animation support (niri cannot animate layer surfaces), and anyrun's fullscreen transparent surface made it feel like it covered the whole screen. Revisit only with a launcher that animates just its own box.

## Awaiting decision / discussion

- **`services.locate` (plocate)**: builds a filename database so `locate foo` is instant instead of walking the filesystem with `find`. Runs a low-priority `updatedb` timer. Default is off in NixOS; needs a yes/no.
- **Waybar workspace module**: optional `niri/workspaces` addition (visual change, not applied).
- **zram tuning**: applied `vm.swappiness = 180` and `vm.page-cluster = 0`. Revisit if disk swap ever gets hammered.

## MIME notes

- Archives (`zip`/`tar`/`7z`/`rar`/...): deliberately unhandled; extract via yazi/7zz.
- Presentations: fixed by shadowing `impress.desktop` with a `NoDisplay=true` copy (associations work, launcher stays clean).
- `text/markdown` and `text/x-markdown` -> Writer; `application/json` -> Firefox (built-in JSON viewer).
- All desktop-entry shadows now use `NoDisplay=true` copies of the real entries instead of `Hidden=true`; the old `Hidden` shadows had also broken video/audio launching via the shadowed `mpv.desktop`.

## Backlog from the deep dive

- **Shell**: atuin, direnv + nix-direnv, delta with git integration, `programs.bat`, television.
- **Nvim (remaining)**: luasnip + blink-cmp snippet preset, optionally snacks.nvim; extra LSPs only if new file types appear (taplo/yamlls/jsonls/bashls/fish_lsp).
- **Yazi (remaining)**: plugin system (chmod, full-border, smart-enter).
- **Desktop apps**: password manager (keepassxc/bitwarden) since Firefox password manager is disabled; localsend; nvtop; gdu/duf; zellij; kdeconnect; vicinae (launcher) and noctalia-shell (Quickshell shell for niri) as experiments; stylix to consolidate everforest theming (niri itself is not a stylix target).
- **Security**: Lanzaboote Secure Boot (works with systemd-boot; firmware Secure Boot currently disabled, test carefully); TPM2 auto-unlock is blocked by firmware (bootctl reports "TPM2 Support: no" -> enable Intel PTT in BIOS first, then `boot.initrd.systemd.tpm2.enable` + `systemd-cryptenroll`); restic backups (none configured yet).
- **ESP32**: platformio and/or arduino-language-server for nvim `.ino` support.
- **Gaming**: steam/proton, mangohud, gamemode if wanted.
- **opencode**: the pinned-commit workaround stays (TODO comment remains in `modules/features/opencode.nix`).
- **adb**: a generic ADB/Fastboot interface udev rule was added. If a phone still isn't detected, capture its `vendor:product` from `lsusb` and add a vendor-specific rule to `modules/features/android.nix`.

## Applied (done)

- Hibernation resume via `boot.resumeDevice = "/dev/mapper/cryptswap"`.
- Lid close locks the screen while undocked (logind `lock` + swayidle `lock` event running swaylock); docked lid close is ignored.
- Soteria polkit agent, styled with everforest via `~/.config/soteria/style.css` (`modules/features/soteria.nix`; the agent loads the CSS at startup, so restart `polkit-soteria.service` after changes). Known failure mode: a stale, never-answered prompt wedges the agent and everything elevated (run0/Mod+U/`nh os switch`) then times out with no prompt on screen. Fix: `systemctl --user restart polkit-soteria.service`. While polkit is down, a user-level home-manager generation can still be applied without root by running `<home-manager-generation>/activate`.
- zram-favouring sysctls.
- `/tmp` cleaned on boot.
- Waybar managed by systemd; manual `pkill waybar` binds and `spawn-at-startup` removed.
- MIME defaults: pdf/images -> Firefox, text/plain -> LibreOffice Writer; `feh` removed.
- nvim RunFile runners trimmed to installed interpreters; `nixfmt` installed.
- OpenCode MCP config unified via `programs.mcp.servers`.
- Neovim: treesitter grammars (json/yaml/toml/lua/vim/vimdoc/markdown/markdown_inline), editor opts (undofile/expandtab/smartcase/scrolloff), fidget, grug-far with `<leader>sr`, mini-surround, render-markdown, ruff LSP.
- Yazi: preview deps (poppler-utils, ffmpeg, 7zz, resvg, imagemagick, chafa); zoxide added to fish with `cd` replaced (`--cmd=cd`), which also enables yazi's `z` jump.
- Nix dev QoL: `keep-derivations`/`keep-outputs`; `nix fmt` via nixfmt-tree (flake `formatter` output); `nh` added with `NH_FLAKE=/home/sean/nixos-config`; `rbs`/`rbb` aliases removed in favour of `nh os switch`/`nh os boot` (`rbu` kept, nh cannot update/commit flake.lock); nix-index-database with `comma` (prebuilt full DB; fish command-not-found integration disabled because it was slow, use `, tool` instead).
- Desktop entries: shadows are now `NoDisplay=true` copies of the real entries instead of `Hidden=true`, so MIME launching works (nvim, mpv, foot, cups, LibreOffice extras).
- Shell: eza (icons + git, aliases ls/ll/la/lla/lt), carapace completions, fzf styled with the everforest palette and height/reverse/border defaults.
- Wallpaper: `assets/everforest.png` (1080p) shown by swaybg via one niri `spawn-at-startup` entry (`modules/features/wallpaper.nix`). The niri overview backdrop stays the layout background color.
- OMP (oh-my-pi): installed from nixpkgs as `pkgs.omp` (version travels with the flake-locked nixpkgs, updated by `rbu`). Declarative `~/.omp/agent/config.yml` (nerd symbol preset, dark-forest theme, quiet startup, self-update checks off) is written by an activation script in `modules/features/omp.nix` because omp locks/rewrites the file at runtime. Fallback fonts for its icons/emoji: `nerd-fonts.symbols-only` + `noto-fonts-color-emoji`. Upstream flake input was not used: its package builds from source (15+ min); nixpkgs' is cached.
- Notifications: caelestia-notifs, a standalone Quickshell config vendored from caelestia-shell v2.4.0 (GPL-3.0, see `modules/features/notifications/LICENSE`) with an everforest palette generated from `theme.nix`. It replaced swaync and owns the `org.freedesktop.Notifications` name. Popups morph on drag up/down to expand, swipe past 30% width to dismiss, hover pauses the timer; DND on `Mod+Shift+D`, clear-all on `Mod+Shift+N` (IPC via `quickshell -c caelestia-notifs ipc call notifs ...`). History persists to `~/.local/state/caelestia-notifs/notifs.json`. Notes for future edits: the popup layer window must stay mapped (1px when idle) or hiding it at height 0 deadlocks the list layout; Quickshell handles `replaces_id` by updating the existing notification in place without re-emitting the server signal, so `NotifData.refresh()` re-shows the popup, restarts the timer and saves; `expire_timeout=0` never expires and timeout-less critical notifications stay visible. Deferred: no fullscreen suppression (niri 26.04 IPC exposes no fullscreen state), no image cache across restarts, no DND toast, app icons are not recoloured. `Mod+U` builds with `nh os build` in the background, then applies the result with a single run0 elevation (one soteria prompt), replacing the notification with success/failure. Log: `~/.cache/nh-os-switch.log`.
- Launcher: fuzzel (everforest) on `Mod+Space`. Anyrun was tried for its fade animation but reverted: its surface is a fullscreen transparent layer window, so with niri blur behind it the whole screen appeared covered. Layer-rule blur now applies only to caelestia-notifs.
- Niri eyecandy: animations enabled (springy workspace-switch/overview, longer window open/close), global window blur with 0.95 opacity, 8px rounded corners (`clip-to-geometry`), and layout shadows on.
- Rebuild speed: `programs.nixvim.enableMan = false`. Home Manager's fish completion generator parses every installed package's man pages; nixvim's 7.3 MB `nixvim.5` config reference took 8.7 s per rebuild (for 4 junk completion lines). Without it, `nixvim-fish-completions` builds in 0.4 s; `man nixvim` is gone (use nixd hover or the online docs).
- Rebuild speed II: `programs.fish.generateCompletions = false` on both NixOS (`modules/sean.nix`) and Home Manager (`modules/features/shell.nix`). The generator parsed ~59 MB of man pages on the system side (perl alone 12.5 MB) and ~17 MB on the HM side (git, HM's own manpage) on every nixpkgs update, all locally built. It also dropped HM `man-paths`/`man-cache` (`mandb`), `manual.manpages.enable = false` (no `man home-configuration.nix`), and `programs.nixvim.enablePrintInit = false` (no `nixvim-print-init`). Completions now come from carapace-bin (799 completers) plus package vendor files; re-add `programs.man.generateCaches = true` if `man -k`/`apropos` for home packages is missed.
