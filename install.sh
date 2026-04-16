#!/bin/bash

echo "Cloning config repo"
nix-shell -p git --command "git clone https://github.com/sean-imus/nixos-config.git ~/nixos-config"

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

echo "Dont forget to add github to known hosts via\n ssh -T git@github.com after you add the ssh public key to github!"
