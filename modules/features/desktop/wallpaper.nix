{ ... }:
{
  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    let
      wallpaper = toString (./. + "/../../../assets/landscape.mp4");
    in
    {
      home.packages = [ pkgs.mpvpaper ];

      programs.niri.settings.spawn-at-startup = [
        {
          argv = [
            "mpvpaper"
            "-f"
            "-o"
            "no-audio --loop"
            "ALL"
            wallpaper
          ];
        }
      ];
    };
}
