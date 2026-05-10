## Priority 1 (Bugs)

- [ ] vscode.nix:45,49 hardcodes `nixos` as hostname for nixd options, but config has `notebook` and `server` -- nixd won't resolve options correctly


## Priority 2 (Low effort, high impact)
- [ ] configure swaylock to look better
- [x] configure mako and use it for some keybind feedback like when I change power profiles ctl setting
- [ ] server.nix is basically empty -- add SSH server, keep it minimal but functional

## Priority 3 (Cleanup & consistency)

- [ ] Most features export `nixosModule = { }` (empty set) -- dead code; simplify to only export what each feature actually needs
- [ ] Duplicate `nixd` in neovim.nix `extraPackages` AND in users/sean.nix `home.packages` -- double install
- [ ] onetime_setup.sh generates SSH key silently -- could warn user if key already exists

## Longer term

- [ ] disko setup with LUKS encryption (from original TODO)
- [ ] Use `specialisation` for different niri keybind profiles instead of the mod-toggle script