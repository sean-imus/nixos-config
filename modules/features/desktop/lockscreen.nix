{ ... }:
{
  flake.modules.homeManager.lockscreen =
    { pkgs, lib, ... }:
    {
      programs.swaylock = {
        enable = true;
        settings = {
          ignore-empty-password = true;
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

      programs.niri.settings.binds."Super+Alt+L" = {
        action.spawn = lib.getExe pkgs.swaylock;
      };
    };
}
