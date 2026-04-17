{ pkgs, ... }:

{
  imports = [
  ];

  home.username = "bella";
  home.homeDirectory = "/home/bella";

  # Use bash
  programs.bash.enable = true;

  # User Packages
  home.packages = with pkgs; [
    firefox
    libreoffice
  ];

  # Don't touch!
  home.stateVersion = "25.11";
}
