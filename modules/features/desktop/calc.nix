{ ... }:
{
  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.python3 ];

      programs.niri.settings = {
        binds."XF86Calculator" = {
          action.spawn = [
            "alacritty"
            "--class"
            "calc"
            "-e"
            "python3"
          ];
        };

        window-rules = [
          {
          matches = [ { app-id = "^calc$"; } ];
          open-floating = true;
          opacity = 0.85;
          background-effect.blur = true;
          }
        ];
      };
    };
}
