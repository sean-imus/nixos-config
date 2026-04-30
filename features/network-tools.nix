{ pkgs, ... }:

{
  nixosModule = { };

  homeManagerModule = {
    # Install Network Related Tools
    home.packages = with pkgs; [
      wget
      dnsutils # dig, nslookup
      ldns # drill
      nmap
    ];
  };
}
