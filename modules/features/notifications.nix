{ pkgs, ... }:
{
  services.mako = {
    enable = true;
    settings = {
      anchor = "top-right";
      background-color = "#2d353b";
      border-color = "#a7c080";
      border-radius = 0;
      border-size = 2;
      default-timeout = 8000;
      font = "JetBrainsMono Nerd Font 10";
      height = 150;
      icons = true;
      margin = 8;
      max-visible = 4;
      padding = 8;
      text-color = "#d3c6aa";
      width = 320;

      "urgency=critical" = {
        border-color = "#e67e80";
      };
      "urgency=low" = {
        border-color = "#7a8478";
      };
    };
  };

  home.packages = [ pkgs.libnotify ];

  systemd.user.services.mako = {
    Unit = {
      Description = "Lightweight Wayland notification daemon";
      ConditionEnvironment = "WAYLAND_DISPLAY";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${pkgs.mako}/bin/mako";
      ExecReload = "${pkgs.mako}/bin/makoctl reload";
      Restart = "on-failure";
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}
