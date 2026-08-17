{ pkgs, ... }:
{
  services.printing.enable = true;

  hardware.sane.enable = true;

  home-manager.sharedModules = [
    {
      home.packages = [ pkgs.simple-scan ];
    }
  ];
}
