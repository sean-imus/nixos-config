{ ... }:
{
  flake.modules.nixos.lockscreen =
    { ... }:
    {
      security.pam.services.hyprlock = { };
    };

  flake.modules.homeManager.lockscreen =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      lockCmd = lib.getExe config.programs.hyprlock.package;
      suspendCmd = "${pkgs.systemd}/bin/systemctl suspend-then-hibernate";
    in
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
              blur_passes = 2;
              blur_size = 7;
              brightness = 0.75;
            }
          ];

          label = [
            {
              text = "$TIME";
              font_size = 90;
              font_family = "monospace";
              color = "rgba(d3c6aaff)";
              position = "0, 160";
              halign = "center";
              valign = "center";
            }
            {
              text = ''cmd[update:60000] date +"%A, %d %B"'';
              font_size = 22;
              color = "rgba(a7c080ff)";
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
              inner_color = "rgba(2d353bcc)";
              outer_color = "rgba(a7c080ff)";
              check_color = "rgba(dbbc7fff)";
              fail_color = "rgba(e67e80ff)";
              font_color = "rgba(d3c6aaff)";
              fade_on_empty = false;
              placeholder_text = "<i>Password...</i>";
            }
          ];
        };
      };

      services.swayidle = {
        enable = true;
        timeouts = [
          {
            timeout = 300;
            command = lockCmd;
          }
          {
            timeout = 1200;
            command = suspendCmd;
          }
        ];
        events = {
          before-sleep = lockCmd;
          lock = lockCmd;
        };
      };

      programs.niri.settings.binds."Super+Alt+L" = {
        action.spawn = lockCmd;
      };
    };
}
