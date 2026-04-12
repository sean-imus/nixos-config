{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader = {
    timeout = 1;
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
    };
  };

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

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

  services.xserver.xkb = {
    layout = "de";
    variant = "";
  };

  console.keyMap = "de";

  # DM/WM
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Sound
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Touchpad Support
  services.libinput.enable = true;

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
    btop
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
