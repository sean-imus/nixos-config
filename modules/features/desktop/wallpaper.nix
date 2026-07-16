{ ... }:
{
  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.swaybg ];

      programs.niri.settings.spawn-at-startup = [
        {
          argv = [
            "swaybg"
            "-c"
            "#000000"
          ];
        }
      ];
    };
}
