{ inputs, ... }:
{
  flake.modules.nixos.notebook =
    { pkgs, ... }:
    {
      imports = with inputs.self.modules.nixos; [
        systemEssential
        printing
        qemu
        rdp-work
        niri
        firefox
        vscode
      ];

      networking.hostName = "notebook";

      hardware = {
        cpu.intel.updateMicrocode = true;
        enableRedistributableFirmware = true;
        bluetooth.enable = true;
      };

      fileSystems."/mnt/ssd" = {
        device = "/dev/disk/by-uuid/A6FC-984F";
        fsType = "exfat";
        options = [
          "x-systemd.automount"
          "x-systemd.device-timeout=5"
          "nofail"
          "noatime"
          "uid=1000"
          "gid=100"
          "umask=0022"
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

      programs.niri.enable = true;

      security.rtkit.enable = true;
      hardware.alsa.enableBluetooth = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      users.mutableUsers = false;
      programs.zsh.enable = true;
      users.users = {
        sean = {
          isNormalUser = true;
          description = "Sean Tietz";
          hashedPassword = "$6$T3H3jI/bBMNzxJHi$wmROphZMsgAahqu2dP/H6pquwXvAoKqJ7BIzvuHpI3BaBj7GSjY6EXaDxTZv21OfRKuE0WriJgdm4hyxMoWC8.";
          extraGroups = [
            "networkmanager"
            "wheel"
          ];
          shell = pkgs.zsh;
        };
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
        users.sean = {
          imports = [ inputs.self.modules.homeManager.sean ];
        };
        sharedModules = [ inputs.vimium-options.homeManagerModules.default ];
      };
    };
}
