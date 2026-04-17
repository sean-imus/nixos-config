{
  config,
  lib,
  pkgs,
  ...
}:

let
  username = "sean";
  markerPath = "/home/${username}/.local/share/nixos/remmina-active";
  useStatic = lib.pathExists markerPath;
in

{
  config = lib.mkIf useStatic {
    networking.networkmanager.ensureProfiles.profiles = {
      "ethernet-static" = {
        interface = "enp44s0";
        type = "ethernet";
        ipv4 = {
          address = "192.168.200.2";
          prefixLength = 24;
          gateway = "192.168.200.1";
          method = "manual";
        };
        ipv4.route-metric = 100;
        ipv6.method = "ignore";
      };
    };
  };
}
