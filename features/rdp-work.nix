{ pkgs, ... }:

{
  nixosModule = {
    # Network Profile for RDP Connection to Work Laptop
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
  };

  homeManagerModule = {
    # Install Freerdp
    home.packages = [ pkgs.freerdp ];

    # Desktop Entry to connect to Work Laptop
    xdg.desktopEntries.rdp-to-work = {
      name = "Connect to Work Laptop";
      exec = "xfreerdp /v:192.168.200.1 /u:stietz /p: /d:ENTEX /f /dynamic-resolution /kbd:layout:0x0407,lang:0x0407";
      terminal = false;
      icon = ../assets/WindowsLogo.png;
    };
  };
}
