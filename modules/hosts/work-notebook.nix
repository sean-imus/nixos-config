{ inputs, ... }:
let
  hostName = "work-notebook";
in
{
  flake.modules.nixos."gaming-notebook" =
    { pkgs, ... }:
    {
      # Import modules for this host
      imports = with inputs.self.modules.nixos; [
        hostDefault
        disko
        persistence
        sean
      ];

      # Disk configuration
      diskoCfg = {
        device = "/dev/disk/by-id/nvme-SAMSUNG_MZALQ512HALU-000L2_S4UKNF0R457642";
        memorySize = 24;
      };

      # Enable PPD for battery life on the go
      services.power-profiles-daemon.enable = true;

      # CPU configuration
      hardware = {
        enableRedistributableFirmware = true;
        cpu.intel.updateMicrocode = true;
      };

      # Graphics configuration
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [ intel-media-driver ];
      };
      environment.variables.LIBVA_DRIVER_NAME = "iHD";
      
      # Enable Bluetooth support
      hardware.bluetooth.enable = true;

      # Enable audio
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

      # Boot options
      boot.initrd.availableKernelModules = [ "nvme" "thunderbolt" "xhci_pci" "usbhid" ];
			boot.kernelModules = [ "kvm-intel" ];

      # Enable hibernation safety net if battery falls to critical levels
      services.upower = {
        enable = true;
        usePercentageForPolicy = true;
        percentageAction = 5;
        criticalPowerAction = "Hibernate";
      };

      # Enable automatic suspending & hibernation behaviour when undocked + on battery
      services.logind.settings.Login = {
        HandleLidSwitch = "suspend-then-hibernate";
        HandleLidSwitchExternalPower = "suspend-then-hibernate";
        HandleLidSwitchDocked = "ignore";
      };

			# Configure hibernation behaviour so shutting the display on power only suspends, and if not on power it hibernates after a certain amount of time
      systemd.sleep.settings.Sleep = {
        HibernateOnACPower = false;
        HibernateDelaySec = 3600;
      };

      # Enable firmware update support
      services.fwupd.enable = true;

      # Set hostname which is also used for the rbs/rbb aliases to determine what host to rebuild
      networking.hostName = hostName;
    };

  # Logic to actually build the NixOS system
  flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" hostName;
}
