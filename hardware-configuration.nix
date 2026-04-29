{
  lib,
  config,
  ...
}:

{
  imports = [ ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usbhid"
    "sdhci_pci"
    "sd_mod"
    "usb_storage"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "kvm-intel"
    "vboxdrv"
    "vboxnetadp"
    "vboxnetflt"
    "i915"  # Enable Intel integrated graphics driver
  ];
  boot.extraModulePackages = [ ];

  boot.kernelParams = [
    "quiet"
  ];

  boot.supportedFilesystems = {
    ntfs = true;
    exfat = true;
  };

  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "ext4";
    options = [
      "noatime"
      "nodiratime"
    ]; # Reduce unnecessary writes
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
      "noatime" # Reduce unnecessary writes
    ];
  };

  # Samsung SSD
  fileSystems."/mnt/ssd" = {
    device = "/dev/disk/by-uuid/A6FC-984F";
    fsType = "exfat";
    options = [
      "x-systemd.automount"
      "x-systemd.device-timeout=5"
      "nofail"
      "uid=1000"
      "gid=100"
      "umask=0022"
      "noatime" # Reduce unnecessary writes
    ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
