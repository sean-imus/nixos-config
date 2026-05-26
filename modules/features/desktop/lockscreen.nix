{ inputs, lib, ... }:
{
  flake.modules.nixos.lockscreen =
    { config, ... }:
    {
      options.userCfg.lockscreen.enable = lib.mkEnableOption "Swaylock lockscreen and swayidle";
      config = lib.mkIf config.userCfg.lockscreen.enable {
        home-manager.users.sean.imports = [ inputs.self.modules.homeManager.lockscreen ];
      };
    };

  flake.modules.homeManager.lockscreen =
    { pkgs, config, lib, ... }:
    {
      config = {
        programs.swaylock = {
          enable = true;
          settings = {
            ignore-empty-password = true;
            daemonize = true;
            show-failed-attempts = true;
            font = "Sans";
            ring-color = "84c906";
            inside-color = "00000088";
            key-hl-color = "84c906";
            bs-hl-color = "ff0000";
            separator-color = "00000000";
            line-color = "00000000";
            text-color = "ffffff";
            text-caps-lock-color = "ffffff";
            indicator-radius = 100;
            indicator-thickness = 10;
          };
        };

        services.swayidle = {
          enable = true;
          timeouts = [
            {
              timeout = 600;
              command = "${lib.getExe pkgs.swaylock} -f";
            }
          ];
          events = {
            before-sleep = "${lib.getExe pkgs.swaylock} -f";
          };
        };

        programs.niri.settings.binds."Super+Alt+L" = {
          action.spawn = lib.getExe pkgs.swaylock;
        };
      };
    };
}
