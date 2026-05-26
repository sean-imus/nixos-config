{ inputs, ... }:
{
  flake.modules.nixos.notebook =
    { config, ... }:
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
        user.sean.gui.enable = true;
        user.sean.dev.enable = true;
      };

      home-manager.users.sean.niri.config.monitorConfig = ''
        output "eDP-1" {
            mode "1920x1080@60"
            position x=0 y=0
        }

        output "Iiyama North America PL2770H 0x0000011F" {
            mode "1920x1080@144"
            position x=-1920 y=0
        }

        output "Iiyama North America PL2770H 0x00000124" {
            mode "1920x1080@143.998"
            position x=-3840 y=0
            focus-at-startup
        }

        output "Iiyama North America PLX2783H 1128255001580" {
            mode "1920x1080@60"
            position x=-5760 y=0
        }

        output "GIGA-BYTE TECHNOLOGY CO., LTD. M27U 23463B001145" {
            mode "3840x2160@60"
            position x=0 y=-1440
            focus-at-startup
        }
      '';

      diskoConfigDevice = "/dev/disk/by-id/nvme-SAMSUNG_MZALQ512HALU-000L2_S4UKNF0R457642";

      networking.hostName = "notebook";

      hardware = {
        enableRedistributableFirmware = true;
        cpu.intel.updateMicrocode = true;
        bluetooth.enable = true;
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

      environment.shellAliases = {
        rbs = "sudo nixos-rebuild switch --flake .#${config.networking.hostName}";
        rbb = "sudo nixos-rebuild boot --flake .#${config.networking.hostName} && reboot";
      };
    };
}
