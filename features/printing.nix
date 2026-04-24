{ pkgs, ... }:

{
  nixosModule = {
    services.printing.enable = true;
    hardware.sane.enable = true;
  };

  homeManagerModule = {
    home.packages = with pkgs; [ simple-scan ];
  };
}
