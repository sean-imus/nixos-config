These should be ran inside the nixos-config directory unless noted otherwise.

# Formatting
`nix run nixpkgs#nixfmt -- **/*.nix`

# Updating inputs AKA updating the system if coupled with rbs/rbb
`nix flake update`

# Rebuilding AKA applying the changes to the config
`rbs` - Rebuilds and switches instantly
`rbb` - Rebuilds and switches on next boot

# Testing
`nix flake check` - Quick test
`nix build .#nixosConfigurations.notebook.config.system.build.toplevel --dry-run 2>&1` - Deep test

# Commit style
Use "https://www.conventionalcommits.org":
`feat(scope): description`, `fix(scope): description`, `docs`, `chore`, `cleanup`

# Updating secrets
`sops modules/features/secrets/secrets.yaml`

# Installation

**This wipes the entire target disk.**

```bash
# 0. Boot a NixOS ISO

# 1. Partition and format
nix-shell -p disko
sudo disko --mode disko --flake github:sean-imus/nixos-config#notebook

# 2. Copy the age key from USB
lsblk
mount --mkdir /dev/sdX1 /usb
mkdir -p /mnt/home/sean/.sops
cp /usb/age.txt /mnt/home/sean/.sops/age.key
chmod 600 /mnt/home/sean/.sops/age.key
chown -R 1000:1000 /mnt/home/sean/.sops

# 3. Place the hashed password
mkdir -p /mnt/home/sean/.secrets
cp /usb/password.txt /mnt/home/sean/.secrets/password.txt
chmod 600 /mnt/home/sean/.secrets/password.txt
chown -R 1000:1000 /mnt/home/sean/.secrets

# 4. Install
sudo nixos-install --no-channel-copy --no-root-password --flake github:sean-imus/nixos-config#notebook && shutdown now

# 5. Unplug USB & boot

# 6. Clone the config for future rebuilds
git clone https://github.com/sean-imus/nixos-config ~/nixos-config
```
