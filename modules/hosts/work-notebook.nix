{ pkgs, ... }:
{
  imports = [
    ./default.nix
    ../users/sean.nix
    ../features/storage/disko.nix
    ../features/desktop/printing.nix
    ../features/desktop/rdp-work.nix
    ../features/desktop/lockscreen.nix
    ../features/desktop/window-managers/niri/default.nix
  ];

  diskoCfg = {
    device = "nvme-SAMSUNG_MZALQ512HALU-000L2_S4UKNF0R457642";
    memorySize = 24;
  };

  networking.hostName = "work-notebook";

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
  # TODO CHECK THIS WHOLE THING I DONT WANT ANYTHING TO HAPPEN WITHOUT ME EXPLICIT, NO SUSPEND NO HIBERNATE, ONLY THAT CRITIAL 5% HIBERNATE THING NO LID SWTICH THINGS HAPPEING EITHER
  systemd.sleep.settings.Sleep = {
    HibernateOnACPower = false;
    HibernateDelaySec = 3600;
  };

  services.fwupd.enable = true;
}
