{ inputs, ... }:
{
  flake.modules.nixos.gaming-notebook =
    { ... }:
    {
      imports = with inputs.self.modules.nixos; [
        desktop
        disko
        persistence
        sean
      ];

      hostCfg = {
        flakePath = ".";
        user.sean = {
          desktop = true;
          dev = true;
        };
      };

      diskoConfigDevice = "/dev/disk/by-id/nvme-SAMSUNG_MZVL21T0HCLR-00B00_S676NX0T429820";

      networking.hostName = "gaming-notebook";

      nixpkgs.config.allowUnfree = true;

      hardware = {
        enableRedistributableFirmware = true;
        cpu.intel.updateMicrocode = true;
        bluetooth.enable = true;
        graphics.enable = true;
        nvidia = {
          modesetting.enable = true;
          nvidiaSettings = true;
          open = false;
        };
      };

      boot.initrd.availableKernelModules = [
        "nvme"
        "xhci_pci"
        "usbhid"
      ];

      boot.kernelModules = [
        "kvm-intel"
        "i915"
        "nvidia"
        "nvidia_drm"
        "nvidia_modeset"
        "nvidia_uvm"
      ];
    };
}
