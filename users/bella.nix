{ pkgs, ... }:

{
  imports = [
    ../../dotfiles/alacritty.nix
  ];

  home.username = "bella";
  home.homeDirectory = "/home/bella";

  # User Packages
  home.packages = with pkgs; [
    firefox
    libreoffice
  ];

  # Don't touch!
  home.stateVersion = "25.11";
}
