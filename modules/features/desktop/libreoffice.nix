{ ... }:
{
  flake.modules.homeManager.libreoffice =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.libreoffice-fresh ];

      xdg.dataFile = {
        "applications/base.desktop".text = ''
          [Desktop Entry]
          Hidden=true
        '';
        "applications/draw.desktop".text = ''
          [Desktop Entry]
          Hidden=true
        '';
        "applications/impress.desktop".text = ''
          [Desktop Entry]
          Hidden=true
        '';
        "applications/math.desktop".text = ''
          [Desktop Entry]
          Hidden=true
        '';
        "applications/startcenter.desktop".text = ''
          [Desktop Entry]
          Hidden=true
        '';
        "applications/xsltfilter.desktop".text = ''
          [Desktop Entry]
          Hidden=true
        '';
      };
    };
}
