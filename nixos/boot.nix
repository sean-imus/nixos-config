# =============================================================================
# BOOT MODULE - Bootloader configuration
# =============================================================================
#
# Configures the system bootloader:
# - systemd-boot: EFI bootloader
# - EFI variables: Allows boot order changes via efibootmgr
# =============================================================================

{ config, lib, ... }:

{
  # =============================================================================
  # OPTIONS - No additional options needed
  # =============================================================================
  options = {
    # This module uses standard NixOS boot options
  };

  # =============================================================================
  # CONFIG - Bootloader settings
  # =============================================================================
  config = {
    # Enable systemd-boot bootloader
    boot.loader.systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };

    # Enable touch EFI variables (allows efibootmgr to work)
    boot.loader.efi.canTouchEfiVariables = true;

    # Version for state (required, keep updated)
    system.stateVersion = "25.11";
  };
}