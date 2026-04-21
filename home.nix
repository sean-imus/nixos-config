{ pkgs, ... }:

{
  imports = [
    ./dotfiles/btop.nix
    ./dotfiles/chromium.nix
    ./dotfiles/git.nix
    ./dotfiles/ssh.nix
    ./dotfiles/alacritty.nix
    ./dotfiles/neovim.nix
    ./dotfiles/opencode.nix
    ./dotfiles/network-tools.nix
    ./dotfiles/remmina.nix
    ./dotfiles/niri/niri.nix
  ];

  home.username = "sean";
  home.homeDirectory = "/home/sean";

  # Use bash
  programs.bash.enable = true;

  # User Packages
  home.packages = with pkgs; [
    libreoffice
    bat
    nixfmt-tree # treefmt
    veracrypt
  ];

  # Don't touch!
  home.stateVersion = "25.11";
}
