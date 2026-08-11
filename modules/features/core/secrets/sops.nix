{ inputs, ... }:
{
  # Use sops-nix for declarative secret management
  flake-file.inputs = {
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.sops =
    { ... }:
    {
      # Import the Home-Manager module of sops-nix
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      # Helps sops find the Age key when you try invoking sops commands
      home.sessionVariables.SOPS_AGE_KEY_FILE = "/keys/age.txt";

      # Tells sops where the secrets file is and where the Age key is that is used to decrypt it
      sops = {
        defaultSopsFile = ./secrets.yaml;
        age.keyFile = "/keys/age.txt";
      };
    };

  flake.modules.nixos.sops =
    { pkgs, config, ... }:
    {
      # Import the nixos module of sops-nix
      imports = [ inputs.sops-nix.nixosModules.sops ];

      # Persist the Age key so booting actually works and so the key doesn't have to be replaced constantly
      preservation.preserveAt."/persist".files = [
        {
          file = "/keys/age.txt";
          mode = "0600";
        }
      ];

      sops = {
        defaultSopsFile = ./secrets.yaml;
        age.keyFile = "/keys/age.txt";
      };

      # Installs sops system-wide so editing the secrets.yaml works
      environment.systemPackages = with pkgs; [ sops ];

      # Sops by default only accepts a .sops.yaml but since it is named sops.yaml here we need to set this
      environment.variables.SOPS_CONFIG = "${config.hostCfg.flakePath}/modules/features/core/secrets/sops.yaml";

      # Keep SOPS_AGE_KEY_FILE across sudo so editing the secrets.yaml file works
      security.sudo.extraConfig = "Defaults env_keep+=SOPS_AGE_KEY_FILE";
    };
}
