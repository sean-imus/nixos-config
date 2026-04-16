{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader = {
    timeout = 3;
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
  };

  # Networking
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  hardware.bluetooth.enable = true;

  # Locale
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

  # Input
  services.libinput.enable = true; # Touchpad Support
  environment.variables = { # temp
    XKB_DEFAULT_LAYOUT = "de"; # temporary for testing
    XKB_DEFAULT_VARIANT = ""; # temp
  };
  console.keyMap = "de-latin1"; # tty Layout

  # DM/WM
  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };
  services.desktopManager.gnome.enable = true;

  # Sound
  security.rtkit.enable = true; # For realtime audio processing
  services.pipewire = {
    enable = true;
    alsa.enable = true; # compat
    alsa.support32Bit = true; # compat
    pulse.enable = true; # compat
  };

  # Users
  users.users.sean = {
    isNormalUser = true;
    description = "Sean Tietz";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # System Packages
  environment.systemPackages = with pkgs; [
    neovim
    wget
    bat
    lm_sensors # sensors
    pciutils # lspci
    usbutils # lsusb
    which
    chromium
    zip
    unzip
    dnsutils # dig, nslookup
    ldns # drill
    nmap
    tldr
  ];

  # Aliases
  environment.shellAliases = {
    rbs = "sudo nixos-rebuild switch";
    n = "nvim";
  };

  # Special
  nix.settings = {
    auto-optimise-store = true;
    download-buffer-size = 536870912; # 512 MiB
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Don't touch!
  system.stateVersion = "25.11";
}
