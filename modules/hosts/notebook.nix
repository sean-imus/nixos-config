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

      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usbhid"
      ];

      boot.kernelModules = [
        "kvm-intel"
        "i915"
      ];

      services.power-profiles-daemon.enable = true;
    };
}
