{
  pkgs,
  config,
  inputs,
  ...
}:
{
  config = {
    environment.shellAliases = {
      rbb = "sudo nixos-rebuild boot --flake .#${config.networking.hostName} && reboot";
      rbs = "sudo nixos-rebuild switch --flake .#${config.networking.hostName}";
    };

    boot.loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.configurationLimit = 10;
      systemd-boot.enable = true;
      timeout = 1;
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

    console.keyMap = "de-latin1";
    environment.variables = {
      XKB_DEFAULT_LAYOUT = "de";
      XKB_DEFAULT_OPTIONS = "caps:escape";
      XKB_DEFAULT_VARIANT = "";
    };
    services.xserver.xkb.layout = "de";
    services.xserver.xkb.options = "caps:escape";

    documentation = {
      doc.enable = false;
      info.enable = false;
      nixos.enable = false;
    };

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = { inherit inputs; };
    };

    networking = {
      networkmanager.enable = true;
      firewall.enable = true;
    };

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

    nixpkgs.config.allowUnfree = true;

    users.mutableUsers = false;

    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
    };

    fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

    environment.systemPackages = with pkgs; [
      iotop
      lm_sensors
      pciutils
      usbutils
      wget
    ];

    system.stateVersion = "26.11";
  };
}
