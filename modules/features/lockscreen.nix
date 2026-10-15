{ pkgs, ... }:
{
  security.pam.services.swaylock = { };

  home-manager.sharedModules = [
    (
      { theme, ... }:
      {
        programs.swaylock = {
          enable = true;
          settings = {
            color = theme.bg0;
            inside-color = theme.bg1;
            ring-color = theme.green;
            key-hl-color = theme.aqua;
            bs-hl-color = theme.red;
            text-color = theme.fg;
          };
        };

        services.swayidle = {
          enable = true;
          events.lock = "${pkgs.swaylock}/bin/swaylock -f";
        };

        wayland.windowManager.niri.settings.binds."Super+Alt+L".spawn-sh = "loginctl lock-session";
      }
    )
  ];
}
