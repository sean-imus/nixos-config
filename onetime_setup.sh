#!/usr/bin/env bash

echo "Backing up Current Configuration"
sudo mv /etc/nixos /etc/nixos.bak

echo "Symlinking Configuration to /etc/nixos"
sudo ln -s ~/nixos-config /etc/nixos

echo "Generating SSH key for GitHub Access"
ssh-keygen -t ed25519 -C "sean.tietz2@gmail.com" -N "" -f ~/.ssh/id_ed25519 -q

echo "Setting GitHub Remote for Pushing Changes"
git -C ~/nixos-config remote set-url origin git@github.com:sean-imus/nixos-config.git

echo "Displaying Public SSH Key for GitHub Setup"
cat ~/.ssh/id_ed25519.pub

echo "Adding GitHub to Known Hosts"
ssh-keyscan github.com >>~/.ssh/known_hosts
