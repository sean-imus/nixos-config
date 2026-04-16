{ pkgs, ... }:

{
  imports = [
    ../dotfiles/btop.nix
    ../dotfiles/chromium.nix
    ../dotfiles/git.nix
    ../dotfiles/ssh.nix
    ../dotfiles/alacritty.nix
    ../dotfiles/bash.nix
    ../dotfiles/neovim.nix
    ../dotfiles/opencode.nix
    ../dotfiles/network-tools.nix
  ];

  home.username = "sean";
  home.homeDirectory = "/home/sean";

  # User Packages
  home.packages = with pkgs; [
    fastfetch
    libreoffice
    bat
    nixfmt-tree # treefmt
  ];

  # Don't touch!
  home.stateVersion = "25.11";
}
