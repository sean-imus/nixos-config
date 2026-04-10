# =============================================================================
# PACKAGES MODULE - System-wide packages
# =============================================================================
#
# Installs system-wide packages available to all users.
# User-specific packages are in home/packages.nix
# =============================================================================

{ config, lib, pkgs, ... }:

{
  options = { };

  config = {
    # System packages - available to all users
    environment.systemPackages = with pkgs; [
      # Editor
      neovim

      # Utilities
      wget
      bat           # Better cat
      btop          # System monitor
      ncdu          # Disk usage analyzer
      zip
      unzip

      # Hardware tools
      lm_sensors    # Temperature/volts (run: sensors)
      pciutils     # PCI devices (run: lspci)
      usbutils    # USB devices (run: lsusb)
      which

      # Network tools
      dnsutils     # dig, nslookup
      ldns        # drill
      nmap
      tldr        # TL;DR pages

      # Development
      nixfmt-tree  # Code formatter (treefmt)

      # Browser
      chromium
    ];

    # Shell aliases (system-wide)
    # Note: User-specific aliases are in home/bash.nix
    environment.shellAliases = {
      rbs = "sudo nixos-rebuild switch";
      n = "nvim";
    };
  };
}