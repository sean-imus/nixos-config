{ inputs, ... }:
let
  hostname = "notebook";
in {
  flake.nixosConfigurations.${hostname} = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      inputs.self.modules.nixos.systemCommon
      inputs.self.modules.nixos.printing
      inputs.self.modules.nixos.rdp-work
      inputs.self.modules.nixos.qemu

      ({ pkgs, ... }: {
        networking.hostName = hostname;

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
          "ahci" "xhci_pci" "thunderbolt" "nvme" "usbhid"
          "sdhci_pci" "sd_mod" "usb_storage" "virtio_blk" "virtio_pci"
        ];

        boot.kernelModules = [ "kvm-intel" "i915" ];

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
            extraGroups = [ "networkmanager" "wheel" ];
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
      })

      inputs.home-manager.nixosModules.home-manager
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.sean = { pkgs, ... }: {
            imports = [
              inputs.self.modules.homeManager.alacritty
              inputs.self.modules.homeManager.btop
              inputs.self.modules.homeManager.firefox
              inputs.self.modules.homeManager.git
              inputs.self.modules.homeManager.mcp
              inputs.self.modules.homeManager.neovim
              inputs.self.modules.homeManager.niri
              inputs.self.modules.homeManager.opencode
              inputs.self.modules.homeManager.printing
              inputs.self.modules.homeManager.rdp-work
              inputs.self.modules.homeManager.shell
              inputs.self.modules.homeManager.ssh
              inputs.self.modules.homeManager.vesktop
              inputs.self.modules.homeManager.vscode
            ];
            home.username = "sean";
            home.homeDirectory = "/home/sean";
            home.packages = with pkgs; [
              libreoffice
              spotify
              nixfmt-tree
              nixfmt
              nixd
            ];
            home.stateVersion = "25.11";
          };
          sharedModules = [ inputs.vimium-options.homeManagerModules.default ];
        };
      }

      {
        nixpkgs.overlays = [
          inputs.nix-vscode-extensions.overlays.default
          inputs.nix-firefox-addons.overlays.default
          (final: prev: {
            waybar = (prev.waybar.override { cavaSupport = true; }).overrideAttrs (oa: {
              buildInputs = (oa.buildInputs or []) ++ [ prev.libepoxy ];
              patches = (oa.patches or []) ++ [ ./niri/waybar/cava-glsl-alpha.patch ];
            });
          })
        ];
      }
    ];
  };
}
