{ lib, ... }:

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
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  # Auto Mount Samsung SSD
  fileSystems."/run/media/sean/Sean" = {
    device = "/dev/disk/by-uuid/A6FC-984F";
    fsType = "exfat";
    options = [
      "rw"
      "nosuid"
      "relatime"
      "fmask=0022"
      "dmask=0022"
      "iocharset=utf8"
      "x-systemd.device-timeout=5s"
      "x-systemd.automount"
      "uid=sean"
      "gid=sean"
    ];
  };

  # Create Mount Directory for Samsung SSD
  systemd.tmpfiles.rules = [
    "d /run/media/sean/Sean 0755 sean sean -"
  ];

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  virtualisation.virtualbox.guest.enable = true;
}
