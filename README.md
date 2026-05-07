# Information

The entry point is `flake.nix`, which loads `configuration.nix` (system-level config: kernel, boot, networking, hardware, services) and `sean.nix` (Home Manager user config: packages, dotfiles, program settings).

Feature modules live in `features/*.nix` and export `{ nixosModule = ...; homeManagerModule = ...; }`. System-level imports go in `configuration.nix`, user-level in `sean.nix`. Niri config is split across `features/niri/niri.nix` (both layers) with extra files (`.kdl`, `.jsonc`, `.css`) in that subdirectory.

# Usage

Run the following commands to install this configuration from a live NixOS image. No guarantee it works — this config is specific to one machine.

## Format Drive

Replace `/dev/sda` with your actual disk (check with `lsblk`):

```
sudo -i

fdisk /dev/sda

g (gpt disk label)
n
1 (partition number)
2048 (first sector)
+500M (EFI partition)
t
1 (EFI System)
n
2
(default)
(default)
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

## Install from Flake

```
nixos-install --flake github:sean-imus/nixos-config#[notebook/server]
reboot
```

## Clone Repo and Symlink

After rebooting into the new system:

```
git clone https://github.com/sean-imus/nixos-config.git ~/nixos-config
~/nixos-config/onetime_setup.sh
```
