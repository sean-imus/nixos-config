{ inputs, ... }:
{
  flake.modules.nixos.sean =
    { config, ... }:
    {
      # Import the sops module for the hashed password
      imports = [ inputs.self.modules.nixos.sops ];

      # Loads this secret very early so login actually works
      sops.secrets.hashed_password.neededForUsers = true;

      # User configuration
      users.users.sean = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        hashedPasswordFile = config.sops.secrets.hashed_password.path;
      };

      # Import the Home-Manager side of sean and the sops module as well
      home-manager.users.sean.imports = with inputs.self.modules.homeManager; [
        sean
        sops
      ];
    };

  flake.modules.homeManager.sean =
    { config, ... }:
    {
      home = {
        username = "sean";
        homeDirectory = "/home/${config.home.username}";
        # The version of Home-Manager this config was created on
        stateVersion = "26.11";
      };

      # Currently in use for GitHub SSH access
      sops.secrets."sean_ssh_id_ed25519" = {
        path = "${config.home.homeDirectory}/.keys/generated_keys/id_ed25519";
        mode = "0600";
      };

      # Git settings
      programs.git.settings.user = {
        name = "sean tietz";
        email = "sean.tietz2@gmail.com";
      };
    };
}
