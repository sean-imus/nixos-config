{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./features/android.nix
    ./features/disk.nix
    ./features/esp32.nix
    ./features/lockscreen.nix
    ./features/niri
    ./features/printing.nix
    ./features/rdp-work.nix
    ./sean.nix
  ];

  networking = {
    hostName = "notebook";
    networkmanager.enable = true;
    firewall.enable = true;
  };

  services = {
    power-profiles-daemon.enable = true;
    thermald.enable = true;

    logind.settings.Login = {
      HandleLidSwitch = "lock";
      HandleLidSwitchExternalPower = "lock";
      HandleLidSwitchDocked = "ignore";
    };

    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };

    upower = {
      enable = true;
      usePercentageForPolicy = true;
      percentageLow = 20;
      percentageCritical = 10;
      percentageAction = 5;
      criticalPowerAction = "Hibernate";
    };

    fwupd.enable = true;

    getty = {
      autologinUser = "sean";
      autologinOnce = true;
    };

    xserver.xkb = {
      layout = "de";
      options = "caps:escape";
    };
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;

    graphics = {
      enable = true;
      extraPackages = [ pkgs.intel-media-driver ];
    };

    bluetooth.enable = true;
  };

  programs.solaar.enable = true;

  environment = {
    variables = {
      LIBVA_DRIVER_NAME = "iHD";
      XKB_DEFAULT_LAYOUT = "de";
      XKB_DEFAULT_OPTIONS = "caps:escape";
      XKB_DEFAULT_VARIANT = "";
    };

    systemPackages = with pkgs; [
      lm_sensors
      pciutils
      usbutils
      ntfs3g
      e2fsprogs
    ];
  };

  security = {
    rtkit.enable = true;
  };

  boot = {
    initrd.availableKernelModules = [
      "nvme"
      "thunderbolt"
      "xhci_pci"
      "usbhid"
    ];

    kernelModules = [ "kvm-intel" ];
    resumeDevice = "/dev/mapper/cryptswap";
    tmp.cleanOnBoot = true;

    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
        editor = false;
      };
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };

    kernel.sysctl = {
      "vm.page-cluster" = 0;
      "vm.swappiness" = 180;
    };
  };

  time.timeZone = "Europe/Berlin";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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
  };

  console.keyMap = "de-latin1";

  documentation = {
    doc.enable = false;
    info.enable = false;
    nixos.enable = false;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "bak";
    extraSpecialArgs = { inherit inputs; };
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
      download-buffer-size = 134217728;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      keep-derivations = true;
      keep-outputs = true;
    };
  };

  users.mutableUsers = false;

  zramSwap.enable = true;

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.symbols-only
    pkgs.noto-fonts-color-emoji
  ];

  system.stateVersion = "26.11";
}
