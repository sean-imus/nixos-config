# Usage
Run the following the commands to use this configuration on a fresh NixOS system, no guarantee it works though, its pretty specific to me.

sudo fdisk /dev/disk

g 
n 
1 
2048 
+500M
t 
1 
n 
2
ENTER
ENTER
w

sudo mkfs.fat -F 32 /dev/sda1
sudo fatlabel /dev/sda1 NIXBOOT
sudo mkfs.ext4 /dev/sda2 -L NIXROOT

sudo mount /dev/disk/by-label/NIXROOT /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/NIXBOOT /mnt/boot

nixos-install --flake github:sean-imus/nixos-config#nixos
