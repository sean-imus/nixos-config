set -eu

export NIX_CONFIG='experimental-features = nix-command flakes
download-buffer-size = 268435456
http-connections = 64'
usb=$1
repo=$(dirname "$(dirname "$(readlink -f "$0")")")
total=$(grep -c '^step ' "$0")
n=0

banner() {
  printf '\033[H\033[2J\033[3J\n  \033[1m%s\033[0m\n\n' "$1"
}

step() {
  n=$((n + 1))
  banner "[$n/$total] $1"
}

swapoff /mnt/swapfile 2> /dev/null || true
umount -R /mnt 2> /dev/null || true
cryptsetup close cryptroot 2> /dev/null || true

step "Partitioning, encrypting and formatting the disk"
nix run "$repo#nixosConfigurations.notebook.config.system.build.destroyFormatMount"

step "Placing the password hash"
install -Dm600 "$usb/Privat/password.txt" /mnt/home/sean/.secrets/password.txt

step "Installing NixOS"
nixos-install --no-channel-copy --no-root-password --flake "$repo#notebook"

step "Moving the config into the home directory"
mv "$repo" /mnt/home/sean/
chown -R 1000:100 /mnt/home/sean

banner "Installation finished"
printf '  Reboot now? [Y/n] '
read -r answer
case $answer in
  ''|y|Y) reboot ;;
esac
