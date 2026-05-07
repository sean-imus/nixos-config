{
  pkgs,
  lib,
  config,
  ...
}:

{
  imports = [
    ./common.nix
    (import ../features/rdp-work.nix { inherit pkgs; }).nixosModule
    (import ../features/qemu.nix { inherit pkgs; }).nixosModule
    (import ../features/printing.nix { inherit pkgs; }).nixosModule
  ];

  # --- System Settings ---
  networking.hostName = "notebook";

  # --- Hardware ---
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

  # Window Manager
  programs.niri.enable = true;

  # Sound
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
    rbs = "sudo nixos-rebuild switch --flake .#${config.networking.hostName}";
    rbb = "sudo nixos-rebuild boot --flake .#${config.networking.hostName} && reboot";
  };

  # --- Optimizations ---

  services.fstrim.enable = true; # Automatic SSD TRIM

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 25;
  };

  # --- Extras ---
  services.fwupd.enable = true; # Firmware Updates
  services.thermald.enable = true; # Thermal Management Daemon
  services.power-profiles-daemon.enable = true; # Battery Optimization
}
