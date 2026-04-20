#!/usr/bin/env bash

echo "Backing up current configuration"
sudo mv /etc/nixos /etc/nixos.bak

echo "Symlinking configuration to /etc/nixos"
sudo ln -s ~/nixos-config /etc/nixos

echo "Generating SSH key for GitHub access"
ssh-keygen -t ed25519 -C "sean.tietz2@gmail.com" -N "" -f ~/.ssh/id_ed25519 -q

echo "Setting GitHub remote for pushing changes"
git -C ~/nixos-config remote set-url origin git@github.com:sean-imus/nixos-config.git

echo "Displaying public SSH key for GitHub setup"
cat ~/.ssh/id_ed25519.pub

echo "Adding GitHub to known hosts"
ssh-keyscan github.com >>~/.ssh/known_hosts
