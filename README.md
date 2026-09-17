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

# License

GPL-3.0-or-later — see [LICENSE](LICENSE). Anyone may use, modify and redistribute
this config and derived versions, provided derivative works carry the same license
and make their source available.

Not covered by this grant: `modules/features/secrets/` (sops-encrypted secrets and
age recipients) and `assets/` (wallpaper artwork).
