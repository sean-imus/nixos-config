{ inputs, ... }:
{
  # Use modularity and automatic flake.nix generation
  imports = [
    inputs.flake-parts.flakeModules.modules
    inputs.flake-file.flakeModules.dendritic
  ];

  # We need Nixpkgs and Home-Manager
  flake-file.inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # I only have x86 hosts
  systems = [ "x86_64-linux" ];

  # Complicated logic to generate actual NixOS builds from the hosts we configure
  flake.lib.mkNixos =
    system: name:
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        inputs.self.modules.nixos.${name}
        inputs.home-manager.nixosModules.home-manager
      ];
    };
}
