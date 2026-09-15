{ ... }:
{
  security.pam.services.swaylock = { };

  home-manager.users.sean.imports = [
    (
      { pkgs, ... }:
      {
        programs.swaylock = {
          enable = true;
          settings = {
            color = "000000";
          };
        };

        services.swayidle = {
          enable = true;
          systemdTargets = [ "graphical-session.target" ];
          events.lock = "${pkgs.swaylock}/bin/swaylock -f";
        };
      }
    )
  ];
}
