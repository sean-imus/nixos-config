# Usage
Run the following commands to install this configuration from a live NixOS Image, no guarantee it works though, its pretty specific to me.

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
