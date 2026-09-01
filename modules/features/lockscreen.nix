{ ... }:
{
  security.pam.services.swaylock = { };

  home-manager.users.sean.imports = [
    (
      { theme, ... }:
      {
        programs.swaylock = {
          enable = true;
          settings = {
            screenshots = true;
            scaling = "fill";
            indicator = true;
            indicator-radius = 120;
            indicator-thickness = 8;
            indicator-x-position = 0;
            indicator-y-position = 0;
            clock = true;
            timestr = "%H:%M";
            datestr = "%A, %d %B";
            font-size = 90;
            font = "monospace";
            color = theme.bg0;
            inside-color = "${theme.bg0}cc";
            ring-color = theme.green;
            ring-ver-color = theme.yellow;
            ring-wrong-color = theme.red;
            inside-ver-color = "${theme.bg0}cc";
            inside-wrong-color = "${theme.bg0}cc";
            line-color = theme.bg0;
            separator-color = theme.bg0;
            text-color = theme.fg;
            show-failed-attempts = true;
          };
        };
      }
    )
  ];
}
