{ shadowDesktopEntries, ... }:
{
  flake.modules.homeManager.media =
    { pkgs, ... }:
    let
      locked = spawn-sh: {
        _props.allow-when-locked = true;
        inherit spawn-sh;
      };
    in
    {
      programs.mpv = {
        enable = true;
        config = {
          hwdec = "vaapi";
          gpu-context = "wayland";
        };
      };

      services.playerctld.enable = true;

      home.packages = [ pkgs.playerctl ];

      xdg.dataFile = shadowDesktopEntries pkgs pkgs.mpv [ "mpv" ];

      wayland.windowManager.niri.settings.binds = {
        "XF86AudioPlay" = locked "playerctl play-pause";
        "XF86AudioStop" = locked "playerctl stop";
        "XF86AudioPrev" = locked "playerctl previous";
        "XF86AudioNext" = locked "playerctl next";
      };
    };
}
