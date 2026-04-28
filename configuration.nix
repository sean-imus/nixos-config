{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    (import ./features/rdp-work.nix { pkgs = pkgs; }).nixosModule
    (import ./features/virtualbox.nix { pkgs = pkgs; }).nixosModule
    (import ./features/printing.nix { pkgs = pkgs; }).nixosModule
    (import ./features/niri/niri.nix { pkgs = pkgs; }).nixosModule
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

  # Window Manager
  programs.niri.enable = true;

  # Sound
  security.rtkit.enable = true; # For realtime Audio processing
  hardware.alsa.enableBluetooth = true; # For Bluetooth Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true; # compatibility
    alsa.support32Bit = true; # compatibility
    pulse.enable = true; # compatibility
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
    brightnessctl # Laptop Monitor Brightness
  ];

  # Aliases
  environment.shellAliases = {
    rbs = "sudo nixos-rebuild switch";
    rbb = "sudo nixos-rebuild boot && reboot";
  };

  # Optimizations
  services.thermald.enable = true;

  # Nix Settings
  nixpkgs.config.allowUnfree = true; # Allow closed source Software
  hardware.enableRedistributableFirmware = true; # Enable Hardware Firmware which allows redistribution
  nix.settings = {
    auto-optimise-store = true;
    download-buffer-size = 536870912; # 512 MiB
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  # Nix Cleanup
  nix = {
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

  # Firmware Updates
  services.fwupd.enable = true;

  # Don't touch!
  system.stateVersion = "25.11";
}
