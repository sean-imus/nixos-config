{ inputs, ... }:
{
  flake.modules.nixos.notebook =
    { ... }:
    {
      imports = with inputs.self.modules.nixos; [
        systemEssential
        disko
        impermanence
        printing
        qemu
        rdp-work
        niri
        sean
      ];

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

      boot.kernelParams = [
        "i915.enable_fbc=1"
        "i915.enable_guc=2"
      ];

      security.rtkit.enable = true;
      hardware.alsa.enableBluetooth = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 25;
      };

      services.fwupd.enable = true;
      services.thermald.enable = true;
      services.power-profiles-daemon.enable = true;

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    };
}
