{ ... }:
let
  colors = import ../../lib/colors.nix;
  rgba = hex: "rgba(${hex}ff)";
  rgbaAlpha = hex: alpha: "rgba(${hex}${alpha})";
in
{
  security.pam.services.hyprlock = { };

  home-manager.sharedModules = [
    {
      programs.hyprlock = {
        enable = true;
        settings = {
          general = {
            hide_cursor = true;
            ignore_empty_input = true;
          };

          background = [
            {
              path = "screenshot";
              blur_passes = 3;
              blur_size = 7;
              brightness = 0.75;
            }
          ];

          label = [
            {
              text = "$TIME";
              font_size = 90;
              font_family = "monospace";
              color = rgba colors.fg;
              position = "0, 160";
              halign = "center";
              valign = "center";
            }
            {
              text = ''cmd[update:60000] date +"%A, %d %B"'';
              font_size = 22;
              color = rgba colors.green;
              position = "0, 60";
              halign = "center";
              valign = "center";
            }
          ];

          input-field = [
            {
              size = "300, 60";
              position = "0, -20";
              halign = "center";
              valign = "center";
              outline_thickness = 2;
              rounding = 12;
              inner_color = rgbaAlpha colors.bg0 "cc";
              outer_color = rgba colors.green;
              check_color = rgba colors.yellow;
              fail_color = rgba colors.red;
              font_color = rgba colors.fg;
              fade_on_empty = false;
              placeholder_text = "<i>Password...</i>";
            }
          ];
        };
      };
    }
  ];
}
