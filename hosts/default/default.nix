# =============================================================================
# HOST CONFIGURATION - Machine-specific settings
# =============================================================================
#
# This module sets host-specific configuration:
# - hostname: Machine name on network
#
# TO ADD A NEW MACHINE:
# 1. Create new directory: hosts/<machine-name>
# 2. Copy this file and adjust hostname
# 3. Use: nixos-rebuild switch --flake .#<machine-name>
# =============================================================================

{ config, lib, ... }:

{
  options = {
    hostname = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "The machine hostname";
    };
  };

  config = {
    # Set hostname
    networking.hostName = config.hostname;

    # User configuration (username is set in home-manager section)
    users.users.sean = {
      isNormalUser = true;
      description = "Sean Tietz";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };
  };
}
