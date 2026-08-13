{ ... }:
{
  flake.modules.homeManager.desktop =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [ swaybg ];

      programs.niri.settings.spawn-at-startup = [
        {
          argv = [
            "swaybg"
            "-i"
            "${../../../assets/wallpaper.png}"
            "-m"
            "fill"
          ];
        }
      ];
    };
}
