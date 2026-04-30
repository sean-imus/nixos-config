# Information
The entry point is `flake.nix`, which loads `configuration.nix` (base system config: disk setup, hardware, and kernel options) and `home.nix` (all user-specific settings). I've modularized as much as possible, moving optional components into separate `.nix` files under the `features/` folder.

Each feature (e.g., `firefox.nix`, `virtualbox.nix`) splits into two sections: one imported by the system-level `configuration.nix`, and another imported only for my user via `home.nix`. This handles features like VirtualBox that need system-wide changes, while letting me set up user-facing options declaratively for all features.

# Usage
Run the following commands to install this configuration from a live NixOS Image, no guarantee it works though, it's pretty specific to me.

## Format Drive
```
sudo -i

fdisk /dev/disk

g (gpt disk label)
n
1 (partition number [1/128])
2048 first sector
+500M last sector (boot sector size)
t
1 (EFI System)
n
2
default (fill up partition)
default (fill up partition)
w (write)

mkfs.fat -F 32 /dev/sda1
fatlabel /dev/sda1 NIXBOOT
mkfs.ext4 /dev/sda2 -L NIXROOT
```

## Mount Drive
```
mount /dev/disk/by-label/NIXROOT /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/NIXBOOT /mnt/boot
```

## Install from GitHub
```
cd /mnt
nixos-install --flake github:sean-imus/nixos-config#nixos
reboot
```

## Clone GitHub Repo and Symlink to Home
```
git clone https://github.com/sean-imus/nixos-config.git ~/nixos-config

~/nixos-config/onetime_setup.sh
```
