{
  pkgs,
  shadowDesktopEntries,
  ...
}:
{
  home.packages = [
    pkgs.libreoffice-stable
    pkgs.the-powder-toy
    pkgs.ddnet
  ];

  services.playerctld.enable = true;

  programs.mpv = {
    enable = true;
    config = {
      hwdec = "vaapi";
      gpu-context = "wayland";
    };
  };

  xdg = {
    dataFile =
      shadowDesktopEntries
        [ pkgs.libreoffice-stable ]
        [
          "base"
          "draw"
          "impress"
          "math"
          "startcenter"
          "xsltfilter"
        ]
      // shadowDesktopEntries [ pkgs.mpv ] [ "mpv" ];

    mimeApps.defaultApplications = {
      "text/markdown" = "writer.desktop";
      "text/plain" = "writer.desktop";
      "text/x-markdown" = "writer.desktop";
    };
  };
}
