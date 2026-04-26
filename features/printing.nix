{ pkgs, ... }:

{
  nixosModule = {
    services.printing.enable = true; # CUPS Daemon
    hardware.sane.enable = true; # Scanning Support
  };

  homeManagerModule = {
    home.packages = with pkgs; [ simple-scan ]; # Scanning GUI
  };
}
