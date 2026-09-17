{ pkgs, ... }:
{
  security.pam.services.swaylock = { };

  home-manager.sharedModules = [
    {
      programs.swaylock = {
        enable = true;
        settings.color = "000000";
      };

      services.swayidle = {
        enable = true;
        systemdTargets = [ "graphical-session.target" ];
        events.lock = "quickshell -c qs-shell ipc call lock lock";
      };
    }
  ];
}
