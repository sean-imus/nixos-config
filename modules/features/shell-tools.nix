{ pkgs, ... }:
{
  programs.bat.enable = true;

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  home.packages = with pkgs; [
    ncdu
    tldr
  ];
}
