#!/usr/bin/env bash

echo "Backing up current configuration"
sudo mv /etc/nixos /etc/nixos.bak

echo "Symlinking configuration to /etc/nixos"
sudo ln -s ~/nixos-config /etc/nixos

echo "Copying hardware configuration from backup"
sudo cp -f /etc/nixos.bak/hardware-configuration.nix ~/nixos-config/

echo "Generating SSH key for GitHub access"
ssh-keygen -t ed25519 -C "sean.tietz2@gmail.com"

echo "Setting GitHub remote for pushing changes"
git -C ~/nixos-config remote set-url origin git@github.com:sean-imus/nixos-config.git

echo "Displaying public SSH key for GitHub setup"
cat ~/.ssh/id_ed25519.pub

echo "Adding GitHub to known hosts (you may see a key mismatch error if the key isn't added to GitHub yet, this is normal)"
ssh -T git@github.com

echo "Rebuilding NixOS configuration which will be applied on next boot. WARNING: This takes some time and shouldn't be interrupted"
sudo nixos-rebuild boot

echo "Finished! Reboot to use your configuration or continue exploring the base GNOME system"
