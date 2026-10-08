{
  flake.modules = {
    nixos.rdp-work = {
      networking.networkmanager.ensureProfiles.profiles.rdp-static-eth = {
        connection = {
          id = "rdp-static-eth";
          type = "ethernet";
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

    homeManager.rdp-work =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.freerdp ];

        xdg.desktopEntries.rdp-to-work = {
          name = "Connect to Work Laptop";
          exec = "xfreerdp /v:192.168.200.1 /u:stietz /p: /d:ENTEX /f /dynamic-resolution /kbd:layout:0x0407,lang:0x0407";
          terminal = false;
        };
      };
  };
}
