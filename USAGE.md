These should be ran inside the nixos-config directory.

# Formatting
`nix run nixpkgs#nixfmt -- **/*.nix`

# Updating inputs
`nix flake update`

# Rebuilding
`rbs` - Rebuilds and switches instantly
`rbb` - Rebuilds and switches on next boot

# Testing
`nix flake check --no-build --no-eval-cache`

# Updating secrets
`sudo sops modules/features/mechanisms/secrets/secrets.yaml`
