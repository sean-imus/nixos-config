{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (import ./features/rdp-work.nix { pkgs = pkgs; }).nixosModule
    (import ./features/virtualbox.nix { pkgs = pkgs; }).nixosModule
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

  # Bluetooth
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

  # Keyboard Layout
  environment.variables = {
    XKB_DEFAULT_LAYOUT = "de";
    XKB_DEFAULT_VARIANT = "";
  };
  console.keyMap = "de-latin1";
  services.xserver.xkb.layout = "de";

  # Display Manager
  services.displayManager.ly.enable = true;

  # Window Managers
  programs.niri.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Sound
  security.rtkit.enable = true; # For realtime audio processing
  hardware.alsa.enableBluetooth = true; # For Bluetooth Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true; # compat
    alsa.support32Bit = true; # compat
    pulse.enable = true; # compat
  };

  # Users
  users.mutableUsers = false;
  users.users = {
    sean = {
      isNormalUser = true;
      description = "Sean Tietz";
      hashedPassword = "$6$T3H3jI/bBMNzxJHi$wmROphZMsgAahqu2dP/H6pquwXvAoKqJ7BIzvuHpI3BaBj7GSjY6EXaDxTZv21OfRKuE0WriJgdm4hyxMoWC8.";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };
  };

  # System Packages
  environment.systemPackages = with pkgs; [
    lm_sensors # sensors
    pciutils # lspci
    usbutils # lsusb
    tldr
    brightnessctl
    font-awesome
    xwayland-satellite
    bluetui
  ];

  # Aliases
  environment.shellAliases = {
    rbs = "sudo nixos-rebuild switch";
    rbb = "sudo nixos-rebuild boot && reboot";
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

  nixpkgs.config.allowUnfree = true;
  hardware.enableRedistributableFirmware = true;

  # Don't touch!
  system.stateVersion = "25.11";
}
