{
  pkgs,
  lib,
  config,
  ...
}:

{
  imports = [
    (import ./features/btop.nix { }).homeManagerModule
    (import ./features/firefox.nix {
      pkgs = pkgs;
      config = config;
    }).homeManagerModule
    (import ./features/git.nix { }).homeManagerModule
    (import ./features/ssh.nix { }).homeManagerModule
    (import ./features/alacritty.nix { }).homeManagerModule
    (import ./features/neovim.nix { pkgs = pkgs; }).homeManagerModule
    (import ./features/opencode.nix { pkgs = pkgs; }).homeManagerModule
    (import ./features/network-tools.nix { pkgs = pkgs; }).homeManagerModule
    (import ./features/niri/niri.nix { pkgs = pkgs; }).homeManagerModule
    (import ./features/rdp-work.nix { pkgs = pkgs; }).homeManagerModule
    (import ./features/printing.nix { pkgs = pkgs; }).homeManagerModule
    (import ./features/vscode.nix { pkgs = pkgs; }).homeManagerModule
  ];

  home.username = "sean";
  home.homeDirectory = "/home/sean";

  # Use bash
  programs.bash.enable = true;

  # User Packages
  home.packages = with pkgs; [
    libreoffice
    nixfmt-tree # treefmt
  ];

  # Don't Touch!
  home.stateVersion = "25.11";
}
