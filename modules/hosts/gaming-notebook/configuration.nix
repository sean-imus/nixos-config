{ inputs, ... }:
{
  flake.modules.nixos.gaming-notebook =
    { lib, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        hostDefault
        disko
        persistence
        sean-desktop
      ];

      hostCfg = {
        flakePath = ".";
        audio.enable = true;
      };

      diskoConfigDevice = "/dev/disk/by-id/nvme-SAMSUNG_MZVL21T0HCLR-00B00_S676NX0T429820";
      diskoSwapSize = "34G";

      networking.hostName = "gaming-notebook";

      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          "claude-code"
          "nvidia-x11"
          "nvidia-settings"
          "nvidia-persistenced"
          "cudatoolkit"
          "vulkan-validation-layers"
        ];

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
