# Usage
Run the following the commands to use this configuration on a fresh NixOS system, no guarantee it works though, its pretty specific to me.

sudo fdisk /dev/disk

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

sudo mkfs.fat -F 32 /dev/sda1
sudo fatlabel /dev/sda1 NIXBOOT
sudo mkfs.ext4 /dev/sda2 -L NIXROOT

sudo mount /dev/disk/by-label/NIXROOT /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/NIXBOOT /mnt/boot

cd /mnt

nixos-install --flake github:sean-imus/nixos-config#nixos
