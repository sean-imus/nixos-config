{ pkgs, ... }:

{
  imports = [
    ./features/btop.nix
    ./features/chromium.nix
    ./features/firefox.nix
    ./features/git.nix
    ./features/ssh.nix
    ./features/alacritty.nix
    ./features/neovim.nix
    ./features/opencode.nix
    ./features/network-tools.nix
    ./features/niri/niri.nix
    ./features/rdp-to-work.nix
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
