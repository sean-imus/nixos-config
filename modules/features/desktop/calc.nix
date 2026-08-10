{ ... }:
{
  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.python3 ];

      programs.niri.settings = {
        binds."XF86Calculator" = {
          action.spawn = [
            "kitty"
            "--class"
            "calc"
            "python3"
          ];
        };

        window-rules = [
          {
            matches = [ { app-id = "^calc$"; } ];
            open-floating = true;
          }
        ];
      };
    };
}
