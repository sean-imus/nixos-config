{ inputs, ... }:
	let
		hostName = "gaming-notebook";
	in
{
	flake.modules.nixos."gaming-notebook" =
	{ pkgs, ... }:
	{
		imports = with inputs.self.modules.nixos; [ hostDefault disko ];

		# Disk configuration
		diskoCfg = {
			device = "!!PLACEHOLDER!!";
			memorySize = 32;
			encrypt = false;
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
		services.xserver.videoDrivers = [ "nvidia" ];
		hardware.nvidia = {
			modesetting.enable = true;
			open = true;
			dynamicBoost.enable = true;
			powerManagement.enable = true;
		};

		# Enable bluetooth support
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

		# Set hostname which is also used for the rbs/rbb aliases to determine what host to rebuild
		networking.hostName = hostName;
		};

	# Logic to actually build the NixOS system
	flake.nixosConfigurations = inputs.self.lib.mkNixos "x86_64-linux" hostName;
}
