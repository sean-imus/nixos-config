{
  pkgs,
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
  hardware = {
    cpu.intel.updateMicrocode = true; # Microcode Updates
    enableRedistributableFirmware = true; # Enable Hardware Firmware
    bluetooth.enable = true;
  };

  # --- Extra Disks ---
  fileSystems."/mnt/ssd" = {
    device = "/dev/disk/by-uuid/A6FC-984F";
    fsType = "exfat";
    options = [
      "x-systemd.automount"
      "x-systemd.device-timeout=5"
      "nofail"
      "noatime"
      "uid=1000"
      "gid=100"
      "umask=0022"
    ];
  };

  # --- Kernel ---
  boot.initrd.availableKernelModules = [
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
    "i915.enable_fbc=1" # Intel GPU Framebuffer Compression for Power Saving
    "i915.enable_guc=2" # Enable Intel GuC Firmware for GPU Decode and Encoding
  ];

  # --- Window Manager ---
  programs.niri.enable = true;

  # --- Sound ---
  security.rtkit.enable = true; # Realtime Audio Processing
  hardware.alsa.enableBluetooth = true; # Bluetooth Audio
  services.pipewire = {
    enable = true;
    alsa.enable = true; # Compatibility
    alsa.support32Bit = true; # Compatibility
    pulse.enable = true; # Compatibility
  };

  # --- Users ---
  users.mutableUsers = false;
  programs.zsh.enable = true;
  users.users = {
    sean = {
      isNormalUser = true;
      description = "Sean Tietz";
      hashedPassword = "$6$T3H3jI/bBMNzxJHi$wmROphZMsgAahqu2dP/H6pquwXvAoKqJ7BIzvuHpI3BaBj7GSjY6EXaDxTZv21OfRKuE0WriJgdm4hyxMoWC8.";
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
      shell = pkgs.zsh;
    };
  };

  # --- Swap ---
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
