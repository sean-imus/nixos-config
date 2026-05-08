{
  description = "Entry Flake";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Extra VSCode Extensions not in nixpkgs
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Declarative Firefox Extensions
    nix-firefox-addons = {
      url = "github:OsiPog/nix-firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Declarative Vimium Settings
    vimium-options = {
      url = "github:uimataso/vimium-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-vscode-extensions,
      nix-firefox-addons,
      vimium-options,
      ...
    }:
    {
      nixosConfigurations = {
        "notebook" = nixpkgs.lib.nixosSystem {
          modules = [
            ./hosts/notebook.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.sean = import ./users/sean.nix;
                sharedModules = [ vimium-options.homeManagerModules.default ];
              };
            }
            {
              nixpkgs.overlays = [
                nix-vscode-extensions.overlays.default
                nix-firefox-addons.overlays.default
                (final: prev: {
                  waybar = (prev.waybar.override { cavaSupport = true; }).overrideAttrs (oa: {
                    buildInputs = (oa.buildInputs or []) ++ [ prev.libepoxy ];
                    patches = (oa.patches or []) ++ [ ./features/niri/waybar-cava-glsl-alpha.patch ];
                  });
                })
              ];
            }
          ];
        };
      };
    };
}
