{ ... }:
{
  flake.modules.homeManager.calc =
    { ... }:
    {
      programs.niri.settings = {
        binds."XF86Calculator" = {
          action.spawn = [
            "alacritty"
            "--class"
            "calc"
            "-e"
            "sh"
            "-c"
            "nix run nixpkgs#python314 && exit"
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
