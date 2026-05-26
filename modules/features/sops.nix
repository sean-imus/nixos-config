{ inputs, lib, ... }:
{
  flake.modules.nixos.sops = {
    options.userCfg.sops.enable = lib.mkEnableOption "SOPS secrets management";
  };

  flake-file.inputs = {
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.sops =
    { config, ... }:
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      sops = {
        defaultSopsFile = ../secrets/secrets.yaml;
        age.keyFile = "${config.home.homeDirectory}/.ssh/sops_age_key";
      };

      sops.secrets."sean_ssh_id_ed25519" = {
        path = "${config.home.homeDirectory}/.ssh/id_ed25519";
        mode = "0600";
      };
    };
}
