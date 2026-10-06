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
        # Lock via qs-shell; fall back to swaylock if the shell is not running
        # (the ipc call exits non-zero without a running instance).
        events.lock = "${pkgs.quickshell}/bin/quickshell -c qs-shell ipc call lock lock || ${pkgs.swaylock}/bin/swaylock -f";
      };
    }
  ];
}
