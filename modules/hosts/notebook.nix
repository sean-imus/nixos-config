{ inputs, ... }:
{
  flake.modules.nixos.notebook =
    { pkgs, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        hostDefault
        disko
        fingerprint
        persistence
        qemu
        sean-desktop
        tailscale
        wifi
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
          enable32Bit = true;
          extraPackages = with pkgs; [ intel-media-driver ];
        };
      };

      environment.variables.LIBVA_DRIVER_NAME = "iHD";

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

      services.upower = {
        enable = true;
        usePercentageForPolicy = true;
        percentageLow = 20;
        percentageCritical = 10;
        percentageAction = 5;
        criticalPowerAction = "Hibernate";
      };

      services.logind.settings.Login = {
        HandleLidSwitch = "suspend-then-hibernate";
        HandleLidSwitchExternalPower = "suspend-then-hibernate";
        HandleLidSwitchDocked = "ignore";
      };

      systemd.sleep.settings.Sleep = {
        HibernateOnACPower = false;
        HibernateDelaySec = 3600;
      };

      home-manager.users.sean.programs.niri.settings.outputs = {
        "eDP-1" = {
          position = {
            x = 0;
            y = 0;
          };
        };
        "Iiyama North America PL2770H 0x0000011F" = {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 144.0;
          };
          position = {
            x = -1920;
            y = 0;
          };
        };
        "Iiyama North America PL2770H 0x00000124" = {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 143.998;
          };
          position = {
            x = -3840;
            y = 0;
          };
          focus-at-startup = true;
        };
        "Iiyama North America PLX2783H 1128255001580" = {
          mode = {
            width = 1920;
            height = 1080;
            refresh = 60.0;
          };
          position = {
            x = -5760;
            y = 0;
          };
        };
        "GIGA-BYTE TECHNOLOGY CO., LTD. M27U 23463B001145" = {
          mode = {
            width = 3840;
            height = 2160;
            refresh = 60.0;
          };
          scale = 1.75;
          position = {
            x = 0;
            y = -1234;
          };
          focus-at-startup = true;
        };
      };
    };

  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" "notebook";
}
