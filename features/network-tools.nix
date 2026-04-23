{ pkgs, ... }:

{
  nixosModule = {};

  homeManagerModule = {
    # Install network related tools
    home.packages = with pkgs; [
      wget
      dnsutils # dig, nslookup
      ldns # drill
      nmap
    ];
  };
}