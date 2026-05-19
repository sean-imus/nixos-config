{ inputs, ... }:
{
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.flake-file.flakeModules.dendritic
  ];

  flake-file.description = "Entry Flake";

  flake-file.nixConfig = {
    extra-substituters = [ "https://attic.xuyh0120.win/lantian" ];
    extra-trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
  };

  flake-file.inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  systems = [ "x86_64-linux" ];

  flake.lib.mkNixos = system: name: {
    ${name} = inputs.nixpkgs.lib.nixosSystem {
      modules = [
        inputs.self.modules.nixos.${name}
        inputs.home-manager.nixosModules.home-manager
        inputs.disko.nixosModules.disko
        { nixpkgs.hostPlatform = system; }
      ];
    };
  };

  flake.nixosConfigurations =
    inputs.self.lib.mkNixos "x86_64-linux" "notebook" // inputs.self.lib.mkNixos "x86_64-linux" "vm";
}
