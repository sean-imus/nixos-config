{ pkgs, ... }:

{
  imports = [
    ./dotfiles/btop.nix
    ./dotfiles/chromium.nix
    ./dotfiles/git.nix
    ./dotfiles/ssh.nix
    ./dotfiles/alacritty.nix
    ./dotfiles/bash.nix
    ./dotfiles/neovim.nix
  ];

  home.username = "sean";
  home.homeDirectory = "/home/sean";

  # User Packages
  home.packages = with pkgs; [
    fastfetch
    lazygit
    libreoffice
    opencode
    nixfmt-tree # treefmt
  ];

  # Don't touch!
  home.stateVersion = "25.11";
}
