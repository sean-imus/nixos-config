{ pkgs, ... }:
{
  home-manager.sharedModules = [
    {
      home.packages = with pkgs; [
        the-powder-toy
        ddnet
      ];
    }
  ];

  programs.steam = {
    enable = true;
  };
}
