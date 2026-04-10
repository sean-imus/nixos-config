# =============================================================================
# HARDWARE CONFIGURATION - Machine-specific hardware settings
# =============================================================================
#
# IMPORTANT: This file is MACHINE-SPECIFIC and should be generated fresh
# for each new machine using: nixos-generate-config
#
# For a new machine:
# 1. Boot from NixOS installer
# 2. Run: sudo nixos-generate-config
# 3. Copy the resulting hardware-configuration.nix here
# =============================================================================

{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [
    "ata_piix"
    "ohci_pci"
    "ehci_pci"
    "ahci"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/8cc908c5-545b-4506-9b59-e2a2084da46a";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/280D-4288";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  virtualisation.virtualbox.guest.enable = true;
}
