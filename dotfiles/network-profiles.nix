{ pkgs, ... }:

{
  networking.networkmanager.ensureProfiles.profiles = {
    "rdp-static-eth" = {
      connection = {
        id = "rdp-static-eth";
        type = "ethernet";
        interface-name = "enp44s0";
      };
      ipv4 = {
        address = "192.168.200.2/24";
        method = "manual";
        "route-metric" = 100;
      };
      ipv6 = {
        method = "ignore";
      };
    };
  };
}
