{ ... }:
{
  flake.modules.homeManager.wallpaper =
    { pkgs, ... }:
    let
      wallpaper = ../../../assets/wallpaper.gif;
    in
    {
      home.packages = [ pkgs.mpvpaper ];

      programs.niri.settings.spawn-at-startup = [
        {
          argv = [
            "mpvpaper"
            "-o"
            "loop-file=inf no-audio scale=nearest"
            "ALL"
            "${wallpaper}"
          ];
        }
      ];
    };
}
