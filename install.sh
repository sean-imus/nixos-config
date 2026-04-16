#!/bin/bash

echo "Backing up old configuration"
sudo mv /etc/nixos /etc/nixos.bak

echo "Symlinking new configuration to configuration directory"
sudo ln -s ~/nixos-config /etc/nixos

echo "Overriding current hardware configuration with new hardware information"
sudo cp -f /etc/nixos.bak/hardware-configuration.nix ~/nixos-config/

echo "Generating SSH Keys for github access"
ssh-keygen -t ed25519 -C "sean.tietz2@gmail.com"

echo "Setting github remote to be able to push changes to config repo"
git -C ~/nixos-config remote set-url origin git@github.com:sean-imus/nixos-config.git

echo "Printing public key for setting up ssh access to config repo"
cat ~/.ssh/id_ed25519.pub

echo "Press \"yes\" here to add github to your known host list to avoid future errors, it will fail if you havent added your public key to github but it will still add it to your known hosts list"
ssh -T git@github.com

echo "Rebuilding NixOS configuration which will be applied on next boot. WARNING: This takes some time and shouldnt be interrupted"
sudo nixos-rebuild boot

echo "Finished! Reboot to use your configuration or explore this base gnome system further"
