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

  home-manager.sharedModules = [
    {
      home.packages = [ pkgs.freerdp ];

      xdg.desktopEntries.rdp-to-work = {
        name = "Connect to Work Laptop";
        exec = "sdl-freerdp /v:192.168.200.1 /u:stietz /p: /d:ENTEX /multimon /dynamic-resolution /kbd:layout:0x0407,lang:0x0407 /wm-class:rdp-work";
        terminal = false;
      };

      wayland.windowManager.niri.settings._children = [
        {
          window-rule._children = [
            {
              match._props = {
                app-id = "^rdp-work$";
              };
              "open-floating" = true;
            }
          ];
        }
      ];
    }
  ];
}
