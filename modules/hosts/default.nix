{ ... }:
{
  flake.modules.nixos.hostDefault =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      options.hostCfg.audio.enable = lib.mkEnableOption "Audio Support";
      options.hostCfg.hm.enable = lib.mkEnableOption "Home-Manager Default";

      config = lib.mkMerge [
        (lib.mkIf config.hostCfg.audio.enable {
          security.rtkit.enable = true;
          hardware.alsa.enableBluetooth = true;
          services.pipewire = {
            enable = true;
            alsa.enable = true;
            alsa.support32Bit = true;
            pulse.enable = true;
          };
        })
        (lib.mkIf config.hostCfg.hm.enable {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
          };
        })

        {
          time.timeZone = "Europe/Berlin";
          i18n.defaultLocale = "en_US.UTF-8";
          i18n.extraLocaleSettings = {
            LC_ADDRESS = "de_DE.UTF-8";
            LC_IDENTIFICATION = "de_DE.UTF-8";
            LC_MEASUREMENT = "de_DE.UTF-8";
            LC_MONETARY = "de_DE.UTF-8";
            LC_NAME = "de_DE.UTF-8";
            LC_NUMERIC = "de_DE.UTF-8";
            LC_PAPER = "de_DE.UTF-8";
            LC_TELEPHONE = "de_DE.UTF-8";
            LC_TIME = "de_DE.UTF-8";
          };

          environment.variables = {
            XKB_DEFAULT_LAYOUT = "de";
            XKB_DEFAULT_VARIANT = "";
          };

          console.keyMap = "de-latin1";
          services.xserver.xkb.layout = "de";

          nix = {
            settings = {
              download-buffer-size = 536870912;
              experimental-features = [
                "nix-command"
                "flakes"
              ];
            };
            gc = {
              automatic = true;
              dates = "weekly";
              options = "--delete-older-than 7d";
            };
            optimise = {
              automatic = true;
              dates = "weekly";
            };
          };

          zramSwap = {
            enable = true;
            algorithm = "zstd";
            memoryPercent = 50;
          };

          system.stateVersion = "25.11";
          nixpkgs.hostPlatform = "x86_64-linux";

          networking = {
            networkmanager.enable = true;
            firewall.enable = true;
          };

          boot.loader = {
            timeout = 1;
            efi.canTouchEfiVariables = true;
            systemd-boot.enable = true;
            systemd-boot.configurationLimit = 10;
          };

          fonts.packages = with pkgs; [
            nerd-fonts.jetbrains-mono
          ];

          environment.systemPackages = with pkgs; [
            lm_sensors
            pciutils
            usbutils
            iotop
            wget
            tldr
            bat
            zsh
          ];

          environment.shellAliases = {
            rbs = "sudo nixos-rebuild switch --flake .#${config.networking.hostName}";
            rbb = "sudo nixos-rebuild boot --flake .#${config.networking.hostName} && reboot";
          };

          services.fwupd.enable = true;
          services.thermald.enable = true;

          users.mutableUsers = false;
        }
      ];
    };
}
