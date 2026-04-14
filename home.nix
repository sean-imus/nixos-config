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

  home.username = "Sean";
  home.homeDirectory = /home/sean;

  home.packages = with pkgs; [
    fastfetch
    lazygit
    libreoffice
    opencode
    nixfmt-tree
  ];

  home.stateVersion = 25.11;
}
