{ config, lib, ... }:

{
  # --- Networking ---
  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  # --- Boot ---
  boot.loader = {
    timeout = 1;
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 10;
  };

  # --- Localization ---
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

  console.keyMap = "de-latin1"; # TTY Keyboard Layout
  services.xserver.xkb.layout = "de"; # X11 Keyboard Layout

  # --- Rebuild Aliases ---
  environment.shellAliases = {
    rbs = "sudo nixos-rebuild switch --flake .#${config.networking.hostName}";
    rbb = "sudo nixos-rebuild boot --flake .#${config.networking.hostName} && reboot";
  };

  # --- Disk Configuration ---
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXROOT";
    fsType = "ext4";
    options = [
      "noatime"
      "nodiratime"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/NIXBOOT";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
      "noatime"
    ];
  };

  # --- Nix Configuration ---
  nixpkgs.config.allowUnfree = true; # Allow Closed Source Software

  nix = {
    settings = {
      auto-optimise-store = true;
      download-buffer-size = 536870912; # 512 MiB
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

  # --- Don't Touch These ---
  system.stateVersion = "25.11"; # When this config was initially created
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux"; # Processor Architecture
}
