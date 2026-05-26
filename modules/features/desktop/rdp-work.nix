{ inputs, lib, ... }:
{
  flake.modules.nixos.rdp-work =
    { config, ... }:
    {
      options.userCfg.rdp-work.enable = lib.mkEnableOption "RDP work user tools (freerdp, desktop entry)";
      options.hostCfg.rdp-work.enable = lib.mkEnableOption "RDP work network profile";

      config = lib.mkMerge [
        (lib.mkIf config.hostCfg.rdp-work.enable {
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
        })
        (lib.mkIf config.userCfg.rdp-work.enable {
          home-manager.users.sean.imports = [ inputs.self.modules.homeManager.rdp-work ];
        })
      ];
    };

  flake.modules.homeManager.rdp-work =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.freerdp ];

      xdg.desktopEntries.rdp-to-work = {
        name = "Connect to Work Laptop";
        exec = "xfreerdp /v:192.168.200.1 /u:stietz /p: /d:ENTEX /f /dynamic-resolution /kbd:layout:0x0407,lang:0x0407";
        terminal = false;
        icon = ../../../assets/windows_logo.png;
      };
    };
}
