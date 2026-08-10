{ inputs, ... }:
{
	flake.modules.nixos."work-notebook" =
	{ ... }:
	{
		imports = with inputs.self.modules.nixos; [ hostDefault disko ];

		config = {
			hardware.alsa.enableBluetooth = true;
			security.rtkit.enable = true;
			services.pipewire = {
				alsa.enable = true;
				alsa.support32Bit = true;
				enable = true;
				pulse.enable = true;
			};
		};
	};
}
