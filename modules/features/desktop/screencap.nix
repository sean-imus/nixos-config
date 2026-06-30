{ ... }:
{
  flake.modules.homeManager.screencap =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.kooha ];

      programs.niri.settings.binds."Mod+Ctrl+Shift+C".action.spawn = "kooha";

      programs.niri.settings.window-rules = [
        {
          matches = [ { app-id = "^kooha$"; } ];
          open-floating = true;
        }
      ];
    };
}
