{ inputs, ... }:
{
  flake.modules.nixos.notebook =
    { ... }:
    {
      imports = with inputs.self.modules.nixos; [
        hostDefault
        disko
        impermanence
        printing
        qemu
        rdp-work
        niri
        sean
      ];

      hostCfg = {
        hm.enable = true;
        audio.enable = true;
      };

      diskoConfigDevice = "/dev/disk/by-id/nvme-SAMSUNG_MZALQ512HALU-000L2_S4UKNF0R457642";

      networking.hostName = "notebook";

      hardware = {
        enableRedistributableFirmware = true;
        cpu.intel.updateMicrocode = true;
        bluetooth.enable = true;
      };

      fileSystems."/mnt/ssd" = {
        device = "/dev/disk/by-uuid/A6FC-984F";
        fsType = "exfat";
        options = [
          "x-systemd.device-timeout=5"
          "x-systemd.automount"
          "noatime"
          "nofail"
          "umask=0022"
          "uid=1000"
          "gid=100"
        ];
      };

      boot.initrd.availableKernelModules = [
        "ahci"
        "xhci_pci"
        "thunderbolt"
        "nvme"
        "usbhid"
        "sdhci_pci"
        "sd_mod"
        "usb_storage"
        "virtio_blk"
        "virtio_pci"
      ];

      boot.kernelModules = [
        "kvm-intel"
        "i915"
      ];

      services.fwupd.enable = true;
      services.thermald.enable = true;
      services.power-profiles-daemon.enable = true;
    };
}
