# Agents and contributors

Rules for this repo. Personal NixOS flake: one host (`notebook`), one user (`sean`), nixos-unstable + home-manager. One formatter, one way of doing each thing, self-contained feature modules.

## Layout

- `flake.nix` — inputs, one `nixosConfigurations.<host>` per machine, `formatter` (nixfmt-tree).
- `modules/notebook.nix` — NixOS host module for `notebook`: boot, disk, hardware, locale, users, nix daemon. Imported by the flake.
- `modules/sean.nix` — the `sean` user and the home-manager import list.
- `modules/features/appearance.nix` — GTK theme, icons, cursor.
- `modules/features/theme.nix` — the palette and UI font, exposed to home-manager modules as the `theme` module argument.
- `modules/features/<name>.nix` — one feature per file (or per directory when it ships assets or a dev guide, e.g. `claude-code/`).
- `modules/features/claude-code/` — `default.nix` is the NixOS side (unfree allowance), `home.nix` the home-manager side (settings, hooks, statusLine, LSP). Its dev guide is `claude-code/README.md`.
- `modules/features/niri/` — `default.nix` is the NixOS side; `keybindings.nix`, `outputs.nix`, `utilities.nix` are the home-manager side.
- `modules/features/quickshell/` — the personal shell (`qs-shell`), home-manager only. Its dev guide is `quickshell/README.md`.
- `assets/` — static files referenced by features (wallpaper image).
- `HANDOFF.md` — transit notes: dismissed ideas, open questions, backlog, durable notes. Temporary; fold anything lasting into the code, `AGENTS.md` or a feature README.

## Module rules

- A feature that only configures the user is a home-manager module, registered in `modules/sean.nix`.
- A feature that needs system options is a NixOS module imported by `modules/notebook.nix`, and attaches its user-level parts with `home-manager.sharedModules`. Never `home-manager.users.<name>.imports` (that hardcodes the user). A few lines of user config may sit inline in that `sharedModules` list; anything larger goes in its own file next to the feature.
- One owner per option: a feature owns the packages, shell aliases, keybinds and generated files it declares. No second module may set the same option for the same purpose.
- Adding a feature = one file in `modules/features/` + one import line.

## Deliberate cross-module dependencies

The only known exceptions to the rules above. Keep this list current.

- Features add their own niri entries from their own module instead of editing `niri/keybindings.nix`: `wallpaper.nix` adds a `spawn-at-startup` entry via `extraConfig`, `quickshell/default.nix` its startup spawn, and binds.
- `quickshell` needs a PAM service for the lock screen, declared in `notebook.nix` (`quickshell-lock`); `lockscreen.nix` keeps a swaylock fallback for it.
- Niri binds and rules may call tools owned by other features (`qs-shell` IPC for lock and brightness, `fuzzel`, `foot`, `chromium-privat`); `mime.nix` also hardcodes `chromium-privat.desktop`. Renaming one of those means grepping `niri/` and `mime.nix`.
- `niri/utilities.nix` reads `config.programs.nixvim` (shadowed `nvim` entry) and `config.home.pointerCursor` (set in `appearance.nix`).
- `quickshell/default.nix` expects `nerd-fonts.symbols-only`, installed in `notebook.nix`.
- `niri/default.nix` attaches `keybindings.nix`, `outputs.nix` and `utilities.nix` via `home-manager.sharedModules`.
- `printing.nix`, `rdp-work.nix`, `lockscreen.nix` and `claude-code/default.nix` (imported by `notebook.nix`) attach their user-level parts the same way.
- The `claude-code/home.nix` statusLine writes `$XDG_RUNTIME_DIR/claude-usage.json`, which `quickshell/qml/services/ClaudeUsage.qml` reads for the bar's `CC <n>%` item. The file format is documented in `claude-code/README.md`.
- `theme` (`features/theme.nix`) and `shadowDesktopEntries` (`features/mime.nix`) are home-manager `_module.args` consumed by many features.
- fish is split on purpose: `programs.fish.enable` and `users.users.sean.shell` live in `modules/sean.nix` (system side), the rest of `programs.fish` in `modules/features/shell.nix`.

## Style

- All colours and the UI font come from `theme` (`modules/features/theme.nix`). Never inline a palette hex or a font family.
- Pure black (`#000000`) is not a palette colour and may stay literal.
- Take it as a module argument in any home-manager module: `{ theme, ... }:`. NixOS modules do not get it.
  - `theme.<colour>` — bare hex, no `#` (`bg0` `bg1` `bg2` `bg3` `bg4` `grey0` `grey1` `grey2` `fg` `red` `orange` `yellow` `green` `aqua` `blue` `purple`).
  - `theme.hex theme.green` -> `"#a7c080"`.
  - `theme.rgba theme.green "44"` -> `"a7c08044"` (8-digit, no prefix: fuzzel's colour form).
  - `theme.rgb.green` -> `"167, 192, 128"` (for CSS `rgb()`/`rgba()`).
  - `theme.fontFamily` -> the UI font.
- `modules/features/mime.nix` is the only place that builds `NoDisplay=true` desktop-entry shadows. It exposes `shadowDesktopEntries` as a home-manager module argument: `{ shadowDesktopEntries, pkgs, ... }:` then `xdg.dataFile = shadowDesktopEntries [ pkgs.libreoffice-stable ] [ "impress" ];`

## Commands

Run in the repo root.

- `nix fmt` — format (nixfmt-tree, RFC style). `nix fmt -- --ci` to check only.
- `nix flake check` — quick test.
- `nix build .#nixosConfigurations.notebook.config.system.build.toplevel --dry-run` — deep evaluation test.
- `nix run nixpkgs#statix -- check .` and `nix run nixpkgs#deadnix -- .` — must report nothing (not installed permanently).
- `nh os switch` — rebuild and switch now. `nh os boot` — rebuild, apply on next boot.
- `rbu` — update flake inputs and commit `flake.lock`.

## Commits

- Conventional Commits (<https://www.conventionalcommits.org>): `feat(scope): ...`, `fix(scope): ...`, `docs`, `chore`, `cleanup`.
- Scope is the module/feature name, e.g. `feat(niri): ...`.

## Docs

- `HANDOFF.md` is a temporary hand-off document and holds only what git can't tell you: dismissed or parked ideas and why, open questions, backlog, durable notes. No changelog entries; `git log` and conventional commits are the changelog.
- A feature's dev guide lives next to the feature (`modules/features/<name>/README.md`). `README.md` stays install-only.

## License

PolyForm Noncommercial 1.0.0 (see `LICENSE`). Contributions are accepted under the same license.
