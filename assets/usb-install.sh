export NIX_CONFIG='experimental-features = nix-command flakes'
exec nix run github:sean-imus/nixos-config#install -- "$(dirname "$(readlink -f "$0")")"
