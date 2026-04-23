{ pkgs, lib, config, ... }:

{
  imports = [
    (import ./features/btop.nix { pkgs = pkgs; }).homeManagerModule
    (import ./features/chromium.nix { pkgs = pkgs; }).homeManagerModule
    (import ./features/firefox.nix { pkgs = pkgs; }).homeManagerModule
    (import ./features/git.nix { pkgs = pkgs; }).homeManagerModule
    (import ./features/ssh.nix { pkgs = pkgs; config = config; }).homeManagerModule
    (import ./features/alacritty.nix { pkgs = pkgs; }).homeManagerModule
    (import ./features/neovim.nix { pkgs = pkgs; }).homeManagerModule
    (import ./features/opencode.nix { pkgs = pkgs; config = config; }).homeManagerModule
    (import ./features/network-tools.nix { pkgs = pkgs; }).homeManagerModule
    ./features/niri/niri.nix
    (import ./features/rdp-work.nix { pkgs = pkgs; }).homeManagerModule
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