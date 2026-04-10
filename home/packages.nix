# =============================================================================
# HOME PACKAGES MODULE - User packages
# =============================================================================
#
# User-specific packages installed via home-manager.
# System packages are in nixos/packages.nix
# =============================================================================

{ config, lib, pkgs, ... }:

{
  options = { };

  config = {
    home.packages = with pkgs; [
      # System info
      fastfetch

      # Git tools
      lazygit
      lazyjournal

      # File tools
      ripgrep    # Recursive grep
      eza       # Modern ls
      fzf       # Fuzzy finder

      # Office
      libreoffice
    ];
  };
}