# AGENTS.md

## Structure

- Entry point: `flake.nix` → `configuration.nix` (system) + `sean.nix` (Home Manager user)
- `features/*.nix` files export `{ nixosModule = ...; homeManagerModule = ...; }`
- System-level imports go in `configuration.nix`, user-level in `sean.nix`
- Niri config lives in `features/niri/` (split across both layers) with extra config files (`.kdl`, `.jsonc`, `.css`)

## Adding a New Feature

Every feature file must export both keys, even if one is empty:

```nix
{ pkgs, config, ... }:  # params depend on what the feature needs
{
  nixosModule = {
    # system-level: services, environment.systemPackages, boot, networking, etc.
  };

  homeManagerModule = {
    # user-level: home.packages, programs.*, home.file, xdg.*, services.*, etc.
  };
}
```

**Parameter patterns:**
- `{ ... }` — no external inputs needed (e.g., `git.nix`, `btop.nix`)
- `{ pkgs, ... }` — needs packages (most features)
- `{ pkgs, config, ... }` — needs config attrs like `config.home.homeDirectory` (e.g., `vscode.nix`, `firefox.nix`)

**Register the feature:**
- System-only → add to `configuration.nix` imports: `(import ./features/foo.nix { pkgs = pkgs; }).nixosModule`
- User-only → add to `sean.nix` imports: `(import ./features/foo.nix { pkgs = pkgs; }).homeManagerModule`
- Both → add to both files independently

**Feature file conventions:**
- Use `with pkgs; [ ... ]` for package lists
- Empty module = `{ }` (not `null` or omitted)
- Config files (kdl, css, jsonc) go in the feature's subdirectory if needed (see `features/niri/`)
- Shared assets (icons, images) go in `assets/`

## Rebuilding

```bash
sudo nixos-rebuild switch --flake .#nixos
```

Aliases defined in `configuration.nix:183`:
- `rbs` = `sudo nixos-rebuild switch`
- `rbb` = `sudo nixos-rebuild boot && reboot`

No lint or auto-check is configured. Formatting tools available: `nixfmt-tree` (treefmt) and `nixfmt`.

## Conventions

- `system.stateVersion` and `home.stateVersion` are set to `"25.11"` — do not change
- `users.mutableUsers = false` — password changes require editing `configuration.nix`
- Hash passwords with `mkpasswd -m sha-512`
- Config is symlinked from `~/nixos-config` to `/etc/nixos` (see `onetime_setup.sh`)
- Flake inputs: `nixpkgs` (nixos-unstable), `home-manager` (follows nixpkgs), `nix-firefox-addons`, `vimium-options`
- Git remote: `git@github.com:sean-imus/nixos-config.git` (set by `onetime_setup.sh`)

## What Goes Where

| Concern | Layer | Example |
|---|---|---|
| Services, kernel, boot, networking | nixosModule | `qemu.nix`, `printing.nix` |
| User packages, dotfiles, program config | homeManagerModule | `neovim.nix`, `alacritty.nix` |
| Shell aliases | homeManagerModule | `opencode.nix` (`c`), `neovim.nix` (`n`) |
| xdg/config file management | homeManagerModule | `niri/niri.nix` (`home.file`, `xdg.configFile`) |
| System packages | nixosModule (`environment.systemPackages`) | `configuration.nix:172` |
| User packages | homeManagerModule (`home.packages`) | `sean.nix:35` |
| User-facing services (mako, starship, playerctld) | homeManagerModule (`services.*`) | `niri/niri.nix`, `shell.nix` |
