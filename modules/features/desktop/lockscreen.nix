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
          color = "000000";
        };
      };

      programs.niri.settings.binds."Super+Alt+L" = {
        action.spawn = lib.getExe pkgs.swaylock;
      };
    };
}
