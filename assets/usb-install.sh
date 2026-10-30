set -eu
[ "$(id -u)" -eq 0 ] || exec sudo sh "$0"

rm -rf /tmp/nixos-config
git clone https://github.com/sean-imus/nixos-config /tmp/nixos-config
exec sh /tmp/nixos-config/assets/install.sh "$(dirname "$(readlink -f "$0")")"
