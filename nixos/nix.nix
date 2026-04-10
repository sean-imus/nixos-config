# =============================================================================
# NIX MODULE - Nix package manager configuration
# =============================================================================
#
# Configures:
# - Experimental features (flakes, nix-command)
# - Automatic garbage collection
# - Store optimization
# =============================================================================

{ config, lib, ... }:

{
  options = { };

  config = {
    # Enable experimental Nix features
    nix.settings = {
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"  # Enable 'nix' command (instead of 'nix-env')
        "flakes"       # Enable flake support
      ];
    };

    # Automatic garbage collection
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };
}