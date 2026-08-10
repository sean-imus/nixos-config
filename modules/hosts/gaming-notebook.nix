{ inputs, ... }:
{
	flake.modules.nixos."gaming-notebook" =
	{ ... }:
	{
		imports = with inputs.self.modules.nixos; [ hostDefault disko ];

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
		networking.hostName = "gaming-notebook";
	};
}
