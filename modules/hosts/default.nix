{ inputs, ... }:
{
  flake.modules.nixos.hostDefault =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      # This lets modules easily get the path to the nixos configuration directory
      options.hostCfg.flakePath = lib.mkOption {
        type = lib.types.str;
        default = "/etc/nixos/nixos-config";
      };

      # Import modules for every host
      imports = with inputs.self.modules.nixos; [
        group-bridge
      ];

      config = {
        # Create 2 aliases for easier rebuilding
        environment.shellAliases = {
          rbb = "sudo nixos-rebuild boot --flake ${config.hostCfg.flakePath}#${config.networking.hostName} && reboot";
          rbs = "sudo nixos-rebuild switch --flake ${config.hostCfg.flakePath}#${config.networking.hostName}";
        };

        # Bootloader configuration
        boot.loader = {
          efi.canTouchEfiVariables = true;
          systemd-boot.configurationLimit = 10;
          systemd-boot.enable = true;
          timeout = 1;
        };

        # Locale settings
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

        # Keyboard settings
        console.keyMap = "de-latin1";
        environment.variables = {
          XKB_DEFAULT_LAYOUT = "de";
          XKB_DEFAULT_OPTIONS = "caps:escape";
          XKB_DEFAULT_VARIANT = "";
        };
        # Even if X11 is unused these are still relevant due to XWayland and some applications taking their defaults from the files these options create
        services.xserver.xkb.layout = "de";
        services.xserver.xkb.options = "caps:escape";

        # These are enabled by default but not needed
        documentation = {
          doc.enable = false;
          info.enable = false;
          nixos.enable = false;
        };

        # Home-Manager settings to not duplicate packages
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
        };

        # Enable sane networking defaults
        networking = {
          networkmanager.enable = true;
          firewall.enable = true;
        };

        # Nix-related optimizations
        nix = {
          channel.enable = false;
          gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 7d";
          };
          optimise = {
            automatic = true;
            dates = "weekly";
          };
          settings = {
            download-buffer-size = 8388608;
            experimental-features = [
              "nix-command"
              "flakes"
            ];
          };
        };

        # Allow the usage of closed-source software
        nixpkgs.config.allowUnfree = true;

        # Configure user settings
        programs.zsh.enable = true;
        users.defaultUserShell = pkgs.zsh;
        users.mutableUsers = false;

        # Configure and enable ZRAM
        zramSwap = {
          enable = true;
          algorithm = "zstd";
          memoryPercent = 50;
        };

        fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ]; # TODO move to Niri module

        # Install default packages
        environment.systemPackages = with pkgs; [
          bat
          iotop
          lm_sensors # sensors
          ncdu
          pciutils # lspci
          tldr
          usbutils # lsusb
          wget
        ];

        # NixOS version that this config was originally created on
        system.stateVersion = "26.11";
      };
    };
}
