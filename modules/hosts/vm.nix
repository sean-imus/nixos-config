{ inputs, ... }:
{
  flake.modules.nixos.vm =
    { ... }:
    {
      imports = with inputs.self.modules.nixos; [
        systemEssential
        disko
        impermanence
        niri
        sean
      ];

      diskoConfigDevice = "/dev/disk/by-id/virtio-ROOT";

      networking.hostName = "vm";

      hardware = {
        enableRedistributableFirmware = true;
        cpu.intel.updateMicrocode = true;
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

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
      };
    };
}
