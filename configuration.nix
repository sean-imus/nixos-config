{
  pkgs,
  lib,
  config,
  ...
}:

{
  imports = [
    (import ./features/rdp-work.nix { inherit pkgs; }).nixosModule
    (import ./features/qemu.nix { inherit pkgs; }).nixosModule
    (import ./features/printing.nix { inherit pkgs; }).nixosModule
    (import ./features/niri/niri.nix { inherit pkgs; }).nixosModule
  ];

  # --- System Settings ---
  system.stateVersion = "25.11"; # Don't Touch!

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

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  # --- Hardware ---
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux"; # Processor Architecture
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware; # Microcode Updates
  hardware.enableRedistributableFirmware = true; # Enable Hardware Firmware
  hardware.bluetooth.enable = true;

  # File Systems
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

  fileSystems."/mnt/ssd" = {
    device = "/dev/disk/by-uuid/A6FC-984F";
    fsType = "exfat";
    options = [
      "x-systemd.automount"
      "x-systemd.device-timeout=5"
      "nofail"
      "uid=1000"
      "gid=100"
      "umask=0022"
      "noatime"
    ];
  };

  boot.supportedFilesystems = {
    ntfs = true;
    exfat = true;
    vfat = true;
  };

  # Kernel
  boot.initrd.availableKernelModules = [
    # Kernel Modules Available while Booting
    "ahci"
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usbhid"
    "sdhci_pci"
    "sd_mod"
    "usb_storage"
    "virtio_blk"
    "virtio_pci"
  ];

  boot.kernelModules = [
    "kvm-intel" # Enable Hardware Virtualization
    "i915" # Enable Intel Integrated Graphics Driver
  ];

  # --- Boot ---
  boot.loader = {
    timeout = 1;
    efi.canTouchEfiVariables = true;
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 10;
  };

  boot.kernelParams = [
    "intel_iommu=on" # Enable IOMMU for PCI-Passthrough
    "i915.enable_fbc=1" # Intel GPU Framebuffer Compression for Power Saving
    "i915.enable_guc=2" # Enable Intel GuC Firmware for GPU Decode and Encoding
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
    "vm.vfs_cache_pressure" = 50;
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  # --- Input & Display ---
  programs.zsh.enable = true;
  services.libinput.enable = true; # Touchpad Support

  # Keyboard Layout
  environment.variables = {
    XKB_DEFAULT_LAYOUT = "de";
    XKB_DEFAULT_VARIANT = "";
  };
  console.keyMap = "de-latin1"; # TTY Keyboard Layout
  services.xserver.xkb.layout = "de";

  # Display Manager
  #services.displayManager.ly.enable = true;

  # Window Manager
  programs.niri.enable = true;
  #services.desktopManager.gnome.enable = true;
  #services.desktopManager.plasma6.enable = true;

  # --- Sound ---
  security.rtkit.enable = true; # Realtime Audio Processing
  hardware.alsa.enableBluetooth = true; # Bluetooth audio
  services.pipewire = {
    enable = true;
    alsa.enable = true; # Compatibility
    alsa.support32Bit = true; # Compatibility
    pulse.enable = true; # Compatibility
  };

  # --- Users ---
  users.mutableUsers = false;
  users.users = {
    sean = {
      isNormalUser = true;
      description = "Sean Tietz";
      hashedPassword = "$6$T3H3jI/bBMNzxJHi$wmROphZMsgAahqu2dP/H6pquwXvAoKqJ7BIzvuHpI3BaBj7GSjY6EXaDxTZv21OfRKuE0WriJgdm4hyxMoWC8.";
      shell = pkgs.zsh;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };
  };

  # --- Packages & Aliases ---
  environment.systemPackages = with pkgs; [
    lm_sensors # Sensors
    pciutils # lspci
    usbutils # lsusb
    tldr
    iotop
    bat
    brightnessctl # Laptop Monitor Brightness
  ];

  environment.shellAliases = {
    rbs = "sudo nixos-rebuild switch";
    rbb = "sudo nixos-rebuild boot && reboot";
  };

  # --- Optimizations ---
  services.thermald.enable = true; # Thermal Management Daemon

  services.power-profiles-daemon.enable = true;

  services.fstrim.enable = true; # Automatic SSD TRIM

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  # --- Nix Configuration ---
  nixpkgs.config.allowUnfree = true; # Allow Closed Source Software

  nix.settings = {
    auto-optimise-store = true;
    download-buffer-size = 536870912; # 512 MiB
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

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

  # --- Services ---
  services.fwupd.enable = true; # Firmware Updates
}
