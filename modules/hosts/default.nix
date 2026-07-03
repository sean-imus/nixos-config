{ inputs, ... }:
{
  # Base every host imports: locale, boot, nix settings, base packages, and the
  # cross-cutting defaults below. Feature buckets (core/dev/desktop) and the
  # user account are layered on top per host.
  flake.modules.nixos.hostDefault =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      imports = with inputs.self.modules.nixos; [ dns ];

      options.hostCfg.audio.enable = lib.mkEnableOption "Audio Support";
      # What the rbs/rbb aliases build from. Defaults to the remote flake so a
      # host without a local checkout still rebuilds; notebook overrides to "."
      # to build from the working tree.
      options.hostCfg.flakePath = lib.mkOption {
        type = lib.types.str;
        default = "github:sean-imus/nixos-config";
      };

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
        {
          environment.shellAliases = {
            rbs = "sudo nixos-rebuild switch --flake ${config.hostCfg.flakePath}#${config.networking.hostName}";
            rbb = "sudo nixos-rebuild boot --flake ${config.hostCfg.flakePath}#${config.networking.hostName} && reboot";
          };
        }

        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            # NM is enabled below for every host, so every user joins its group
            # here (via the user-groups bridge) rather than in a separate module.
            sharedModules = [ { userCfg.extraGroups = [ "networkmanager" ]; } ];
          };

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
            XKB_DEFAULT_OPTIONS = "caps:escape";
          };

          console.keyMap = "de-latin1";
          services.xserver.xkb.layout = "de";
          services.xserver.xkb.options = "caps:escape";

          nix = {
            channel.enable = false;
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

          documentation.nixos.enable = false;
          documentation.doc.enable = false;

          zramSwap = {
            enable = true;
            algorithm = "zstd";
            memoryPercent = 50;
          };

          system.stateVersion = "25.11";
          # Allowlist rather than blanket allowUnfree — only claude-code is unfree.
          nixpkgs.config.allowUnfreePredicate = lib.mkDefault (
            pkg: builtins.elem (lib.getName pkg) [ "claude-code" ]
          );

          programs.zsh.enable = true;

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
            ncdu
          ];

          services.fwupd.enable = true;

          # Passwords are declarative (sops hashedPasswordFile); block runtime
          # passwd/useradd so the config stays the single source of truth.
          users.mutableUsers = false;
        }
      ];
    };
}
