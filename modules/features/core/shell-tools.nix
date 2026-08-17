{ pkgs, ... }:
{
  programs.bat.enable = true;

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    ncdu
    tldr
  ];
  # TLDR, BAT, NCDU, FZF
}
