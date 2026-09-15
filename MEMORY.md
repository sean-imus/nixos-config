# MEMORY

Parked ideas and decisions from the config deep dive (2026-09-15). Only the items marked "done" were applied.

## Dismissed for now

- **Notification daemon (mako/swaync)**: dismissed. No use case currently.
- **Idle timeouts (auto lock/blank/suspend via swayidle)**: dismissed on purpose. Only the 5% hibernate safeguard and lid-close locking are wanted.
- **Avahi/mDNS for printer/scanner discovery**: dismissed. Printing worked without it; Avahi only adds automatic discovery, not functionality.
- **nixvim `inputs.nixpkgs.follows = "nixpkgs"`**: do not add. Upstream nixvim explicitly recommends against it; update nixvim and nixpkgs together instead.
- **Fingerprint reader (ELAN 04f3:0c4b)**: not viable. Not supported by open-source libfprint; requires Lenovo's proprietary TOD blob.

## Awaiting decision / discussion

- **`services.locate` (plocate)**: builds a filename database so `locate foo` is instant instead of walking the filesystem with `find`. Runs a low-priority `updatedb` timer. Default is off in NixOS; needs a yes/no.
- **Nix development QoL**: `nix.settings.keep-derivations`/`keep-outputs` (keeps build outputs and derivations from GC so dev shells and `nix develop` don't rebuild; costs disk space), flake `formatter` output with nixfmt-tree (`nix fmt` instead of the `nix run nixpkgs#nixfmt -- **/*.nix` ritual), treefmt/git-hooks for auto-format on commit.
- **Extra MIME defaults**: see "MIME gaps" below.
- **Waybar workspace module**: optional `niri/workspaces` addition (visual change, not applied).
- **zram tuning**: applied `vm.swappiness = 180` and `vm.page-cluster = 0`. Revisit if disk swap ever gets hammered.

## MIME gaps (proposal, not applied)

Currently still unhandled or questionable:
- `application/zip`, `application/x-tar` and other archives: no handler (would need e.g. file-roller/ark).
- `text/markdown`, `application/json`: no handler.
- Presentations (odp/pptx): `impress.desktop` is hidden in `office.nix`, so the association is broken.
- `application/vnd.oasis.opendocument.spreadsheet` etc.: calc.desktop works (not hidden).
- `text/csv` already maps to calc.desktop; audio already maps to mpv.desktop.

## Backlog from the deep dive

- **Shell**: zoxide, atuin, carapace, direnv + nix-direnv, nix-index (+ nix-index-database for `,`), nh (`FLAKE = "~/nixos-config"`), eza, delta with git integration, `programs.bat`, fzf everforest colors, television.
- **Nvim (remaining)**: luasnip + blink-cmp snippet preset, optionally snacks.nvim; extra LSPs only if new file types appear (taplo/yamlls/jsonls/bashls/fish_lsp).
- **Yazi**: poppler (PDF), ffmpeg + ffmpegthumbnailer (video), 7zip or ouch (archives), resvg (SVG), imagemagick, chafa (foot has no graphics protocol), fzf + zoxide for its jump features; yazi plugin system.
- **Desktop apps**: password manager (keepassxc/bitwarden) since Firefox password manager is disabled; localsend; nvtop; gdu/duf; zellij; kdeconnect; vicinae (launcher) and noctalia-shell (Quickshell shell for niri) as experiments; stylix to consolidate everforest theming (niri itself is not a stylix target).
- **Security**: Lanzaboote Secure Boot (works with systemd-boot; firmware Secure Boot currently disabled, test carefully); TPM2 auto-unlock is blocked by firmware (bootctl reports "TPM2 Support: no" -> enable Intel PTT in BIOS first, then `boot.initrd.systemd.tpm2.enable` + `systemd-cryptenroll`); restic backups (none configured yet).
- **ESP32**: platformio and/or arduino-language-server for nvim `.ino` support.
- **Gaming**: steam/proton, mangohud, gamemode if wanted.
- **opencode**: the pinned-commit workaround stays (TODO comment remains in `modules/features/opencode.nix`).
- **adb**: a generic ADB/Fastboot interface udev rule was added. If a phone still isn't detected, capture its `vendor:product` from `lsusb` and add a vendor-specific rule to `modules/features/android.nix`.

## Applied (done)

- Hibernation resume via `boot.resumeDevice = "/dev/mapper/cryptswap"`.
- Lid close locks the screen while undocked (logind `lock` + swayidle `lock` event running swaylock); docked lid close is ignored.
- Soteria polkit agent.
- zram-favouring sysctls.
- `/tmp` cleaned on boot.
- Waybar managed by systemd; manual `pkill waybar` binds and `spawn-at-startup` removed.
- MIME defaults: pdf/images -> Firefox, text/plain -> LibreOffice Writer; `feh` removed.
- nvim RunFile runners trimmed to installed interpreters; `nixfmt` installed.
- OpenCode MCP config unified via `programs.mcp.servers`.
- Neovim: treesitter grammars (json/yaml/toml/lua/vim/vimdoc/markdown/markdown_inline), editor opts (undofile/expandtab/smartcase/scrolloff), fidget, grug-far with `<leader>sr`, mini-surround, render-markdown, ruff LSP.
