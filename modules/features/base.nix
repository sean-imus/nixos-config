{ den, ... }:
{
  den.aspects.base.includes = with den.aspects; [
    den.batteries.hostname
    boot
    filesystem-tools
    firmware
    home-manager-settings
    immutable-users
    locale
    minimal
    networking
    nix-settings
    zram
  ];
}
