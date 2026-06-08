{ inputs, ... }:
{
  flake.modules.nixos.notebook =
    { pkgs, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        hostDefault
        disko
        persistence
        qemu
        sean-desktop
        tailscale
      ];

      hostCfg = {
        flakePath = ".";
        audio.enable = true;
      };

      diskoConfigDevice = "/dev/disk/by-id/nvme-SAMSUNG_MZALQ512HALU-000L2_S4UKNF0R457642";
      diskoSwapSize = "26G";

      networking.hostName = "notebook";

      hardware = {
        enableRedistributableFirmware = true;
        cpu.intel.updateMicrocode = true;
        bluetooth.enable = true;
        graphics = {
          enable = true;
          extraPackages = with pkgs; [ intel-media-driver ];
        };
      };

      boot.initrd.availableKernelModules = [
        "nvme"
        "thunderbolt"
        "xhci_pci"
        "usbhid"
      ];

      boot.kernelModules = [
        "kvm-intel"
        "i915"
      ];

      services.power-profiles-daemon.enable = true;
      services.thermald.enable = true;
    };

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "notebook";
}
