# =============================================================================
# USERS MODULE - User account configuration
# =============================================================================
#
# Configures:
# - Primary user groups (wheel, networkmanager)
# - Shell aliases
# =============================================================================

{ config, lib, ... }:

{
  options = { };

  config = {
    # User configuration is set in hosts/default/default.nix
    # Here we add groups and other user-specific settings
    users.users.sean = {
      extraGroups = [
        "networkmanager"  # Allow NetworkManager control
        "wheel"        # Allow sudo access
      ];
    };

    
  };
}