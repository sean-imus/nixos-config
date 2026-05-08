# TODO - Quick wins first

## Priority 1 (Bugs)

- [ ] vscode.nix:45,49 hardcodes `nixos` as hostname for nixd options, but config has `notebook` and `server` -- nixd won't resolve options correctly
- [ ] git.nix:20-21 uses `Name`/`Email` (capitalized) -- works (git keys are case-insensitive) but unconventional; stick to lowercase `name`/`email`

## Priority 2 (Low effort, high impact)

- [ ] flake.nix: add `formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt` so `nix fmt` works
- [ ] flake.nix: add `nixConfig` block with `trusted-users = [ "root" "@wheel" ]` and `substituters` / `extra-trusted-public-keys`
- [ ] server.nix is basically empty -- add SSH server, keep it minimal but functional

## Priority 3 (Cleanup & consistency)

- [ ] Most features export `nixosModule = { }` (empty set) -- dead code; simplify to only export what each feature actually needs
- [ ] `.gitignore` only has `result` -- add `result-*`, `.direnv/`, `flake.lock` isn't needed (it's tracked on purpose)
- [ ] `nodiratime` in mount options is deprecated; `noatime` already implies it
- [ ] Duplicate `nixd` in neovim.nix `extraPackages` AND in users/sean.nix `home.packages` -- double install
- [ ] README.md: fdisk-based disk setup instructions are dated -- consider updating or adding disko note
- [ ] onetime_setup.sh generates SSH key silently -- could warn user if key already exists

## Longer term

- [ ] disko setup with LUKS encryption (from original TODO)
- [ ] Use `specialisation` for different niri keybind profiles instead of the mod-toggle script
- [ ] Add CI (e.g. `nix flake check` in GitHub Actions)
