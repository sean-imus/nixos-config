{ inputs, ... }:
{
  flake.modules.nixos.vm =
    { ... }:
    {
      imports = with inputs.self.modules.nixos; [
        hostDefault
        disko
        impermanence
        niri
        sean
      ];

      diskoConfigDevice = "/dev/disk/by-id/virtio-ROOT";

      networking.hostName = "vm";

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
      ];

      hostCfg.audio.enable = true;

      hostCfg.hm.enable = true;
    };
}
