# =============================================================================
# NETWORKING MODULE - Network configuration
# =============================================================================
#
# Configures basic networking:
# - NetworkManager for device management
# - Hostname (set in hosts/default/default.nix)
# =============================================================================

{ config, lib, ... }:

{
  options = { };

  config = {
    # Enable NetworkManager (handles WiFi/Ethernet automatically)
    networking.networkmanager.enable = true;
  };
}
