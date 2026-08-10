{ ... }:
{
	# Use preservation to persist files & folders on an impermanent root
  flake-file.inputs = {
    preservation = {
      url = "github:nix-community/preservation";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

	flake.modules.nixos.persistence =
	{ lib, config, inputs, ... }:
	{
		# Import preservations NixOS module to use its options
		imports = [ inputs.preservation.nixosModules.default ];

		# This does not work on an impermanent NixOS system, instead the machine-id is preserved below
		systemd.services."systemd-machine-id-commit".enable = false;

		home-manager.sharedModules = [
			(
				{ ... }:
				{
					# Functionality to allow Home-Manager modules to declare the files they need persisted themselves
					options.persist = {
						files = lib.mkOption {
							type = with lib.types; listOf (either str (attrsOf anything));
							default = [ ];
						};
						directories = lib.mkOption {
							type = with lib.types; listOf (either str (attrsOf anything));
              default = [ ];
						};
					};
					# Everyone gets a user owned peristed directory under ~/persist
					config.persist.directories = [ "persist" ];
				}
			)
		];
	};
}
