{ pkgs, ... }:
{
  services.printing.enable = true;

  hardware.sane.enable = true;

  environment.systemPackages = [ pkgs.simple-scan ];

  home-manager.sharedModules = [
    (
      { shadowDesktopEntries, ... }:
      {
        xdg.dataFile = shadowDesktopEntries [ pkgs.cups ] [ "cups" ];
      }
    )
  ];
}
