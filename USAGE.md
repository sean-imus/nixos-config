These should be ran inside the nixos-config directory.

# Formatting
`nix run nixpkgs#nixfmt -- **/*.nix`

# Updating inputs AKA updating the system if coupled with rbs/rbb
`nix flake update`

# Rebuilding AKA applying the changes to the config
`rbs` - Rebuilds and switches instantly
`rbb` - Rebuilds and switches on next boot

# Testing
`nix flake check --no-build --no-eval-cache`

# Updating secrets
`sudo sops modules/features/core/secrets/secrets.yaml`
