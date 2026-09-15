# Contributing

Rules for this repo. Personal NixOS flake: one host (`notebook`), one user (`sean`), nixos-unstable + home-manager. One formatter, one way of doing each thing, self-contained feature modules.

## Layout

- `flake.nix` — inputs, one `nixosConfigurations.<host>` per machine, `formatter` (nixfmt-tree).
- `modules/notebook.nix` — NixOS host module for `notebook`: boot, disk, hardware, locale, users, nix daemon. Imported by the flake.
- `modules/sean.nix` — the `sean` user and the home-manager import list.
- `modules/features/<name>.nix` — one feature per file.
- `modules/features/niri/` — `default.nix` is the NixOS side; `keybindings.nix`, `outputs.nix`, `utilities.nix` are the home-manager side.
- `modules/features/secrets/` — sops config (`sops.nix`), age recipients (`sops.yaml`), the encrypted file (`secrets.yaml`).
- `modules/lib/` — plain helper functions, no options.
- `assets/` — static files referenced by features (wallpaper image).
- `MEMORY.md` — decision log: dismissed ideas, open questions, backlog.

## Module rules

- A feature that only configures the user is a home-manager module, registered in `modules/sean.nix`.
- A feature that needs system options is a NixOS module imported by `modules/notebook.nix`, and attaches its user-level parts with `home-manager.sharedModules`. Never `home-manager.users.<name>.imports` (that hardcodes the user), never an inline user module.
- One owner per option: a feature owns the packages, shell aliases, keybinds and generated files it declares. No second module may set the same option for the same purpose.
- Adding a feature = one file in `modules/features/` + one import line.

## Deliberate cross-module dependencies

The only known exceptions to the rules above. Keep this list current.

- Features add their own niri entries from their own module instead of editing `niri/keybindings.nix`: `rebuild.nix` extends `wayland.windowManager.niri.settings` with the `Mod+U` bind, `wallpaper.nix` adds a `spawn-at-startup` entry via `extraConfig`.
- `niri/default.nix` attaches `keybindings.nix`, `outputs.nix` and `utilities.nix` via `home-manager.sharedModules`.
- `printing.nix`, `rdp-work.nix` and `lockscreen.nix` attach their user-level parts the same way.
- `ssh.nix` declares and consumes its own `sops.secrets."ssh_key"`; `secrets/sops.nix` keeps the sops defaults and the age key path.
- fish is split on purpose: `programs.fish.enable` and `users.users.sean.shell` live in `modules/sean.nix` (system side), the rest of `programs.fish` in `modules/features/shell.nix`.

## Style

- All colours and the UI font come from `modules/lib/theme.nix`. Never inline a palette hex or a font family.
- Import it in a `let` block: `theme = import ../lib/theme.nix;` (`../../lib/theme.nix` from `modules/features/niri/`).
  - `theme.<colour>` — bare hex, no `#` (`bg0` `bg1` `bg2` `bg3` `bg4` `grey0` `grey1` `grey2` `fg` `red` `orange` `yellow` `green` `aqua` `blue` `purple`).
  - `theme.hex theme.green` -> `"#a7c080"`.
  - `theme.rgba theme.green "44"` -> `"a7c08044"` (8-digit, no prefix: fuzzel's colour form).
  - `theme.rgb.green` -> `"167, 192, 128"` (for CSS `rgb()`/`rgba()`).
  - `theme.fontFamily` -> the UI font.
- `modules/lib/desktop-entries.nix` is the only place that builds `NoDisplay=true` desktop-entry shadows:
  `shadowDesktopEntries = import ../lib/desktop-entries.nix { inherit pkgs; };` then `xdg.dataFile = shadowDesktopEntries [ pkgs.libreoffice-stable ] [ "impress" ];`

## Commands

Run in the repo root.

- `nix fmt` — format (nixfmt-tree, RFC style). `nix fmt -- --ci` to check only.
- `nix flake check` — quick test.
- `nix build .#nixosConfigurations.notebook.config.system.build.toplevel --dry-run` — deep evaluation test.
- `statix check .` and `deadnix .` — must report nothing.
- `nh os switch` — rebuild and switch now. `nh os boot` — rebuild, apply on next boot.
- `rbu` — update flake inputs and commit `flake.lock`.

## Commits

- Conventional Commits (<https://www.conventionalcommits.org>): `feat(scope): ...`, `fix(scope): ...`, `docs`, `chore`, `cleanup`.
- Scope is the module/feature name, e.g. `feat(niri): ...`.

## Secrets

- `sops modules/features/secrets/secrets.yaml` — edit the encrypted secrets.
- Age key: `/home/sean/.sops/age.key`.
- Recipients: `modules/features/secrets/sops.yaml`.
