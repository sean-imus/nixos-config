## Installation

**This wipes the entire target disk.**

```bash
# 0. Boot a NixOS ISO

# 1. Partition and format
nix-shell -p disko
sudo disko --mode disko --flake github:sean-imus/nixos-config#[notebook|vm]

# 2. Copy the age key from USB (needed to boot after install)
lsblk
mkdir -p /usb && mount /dev/sdX1 /usb
mkdir -p /mnt/persist/home/sean/.keys
cp /usb/keys.txt /mnt/persist/home/sean/.keys/age.txt
chmod 600 /mnt/persist/home/sean/.keys/age.txt
umount /usb

# 3. Install
sudo nixos-install --no-channel-copy --no-root-password --flake github:sean-imus/nixos-config#[notebook|vm]
```
