{
  description = "Entry Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-firefox-addons = {
      url = "github:OsiPog/nix-firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      nix-firefox-addons,
      ...
    }:
    let
      overlay = final: prev: {
        python3Packages = prev.python3Packages.override {
          overrides = python-self: python-super: {
            aioboto3 = python-super.aioboto3.overridePythonAttrs (old: {
              doCheck = false;
            });
            aiobotocore = python-super.aiobotocore.overridePythonAttrs (old: {
              doCheck = false;
            });
            fastmcp = python-super.fastmcp.overridePythonAttrs (old: {
              doCheck = false;
            });
          };
        };
      };
    in
    {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.sean = import ./sean.nix;
            }
            {
              nixpkgs.overlays = [
                nix-firefox-addons.overlays.default
                overlay
              ];
            }
          ];
        };
      };
    };
}
