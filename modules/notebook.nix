{
  pkgs,
  config,
  inputs,
  ...
}:
{
  imports = [
    ./sean.nix
    ./features/disk.nix
    ./features/printing.nix
    ./features/rdp-work.nix
    ./features/lockscreen.nix
    ./features/niri
    ./features/gaming.nix
  ];

  networking.hostName = "notebook";

  services.power-profiles-daemon.enable = true;

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [ pkgs.intel-media-driver ];
  };
  environment.variables.LIBVA_DRIVER_NAME = "iHD";

  hardware.bluetooth.enable = true;

  hardware.alsa.enableBluetooth = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
  };

  boot.initrd.availableKernelModules = [
    "nvme"
    "thunderbolt"
    "xhci_pci"
    "usbhid"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  services.upower = {
    enable = true;
    usePercentageForPolicy = true;
    percentageAction = 5;
    criticalPowerAction = "Hibernate";
  };

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  services.fwupd.enable = true;

  environment.shellAliases = {
    rbb = "sudo nixos-rebuild boot --flake .#notebook && reboot";
    rbs = "sudo nixos-rebuild switch --flake .#notebook";
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
}
