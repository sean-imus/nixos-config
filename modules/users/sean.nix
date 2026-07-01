{ inputs, ... }:
{
  flake.modules.nixos.sean =
    { pkgs, config, ... }:
    {
      imports = [ inputs.self.modules.nixos.sops ];

      config = {
        sops.secrets.sean_hashed_password = {
          neededForUsers = true;
        };

        users.users.sean = {
          isNormalUser = true;
          description = "Sean Tietz";
          linger = true;
          hashedPasswordFile = config.sops.secrets.sean_hashed_password.path;
          shell = pkgs.zsh;
          # wheel is genuine user identity; feature groups resolve via the
          # user-groups bridge from the HM features this user imports.
          extraGroups = [ "wheel" ];
        };

        home-manager.users.sean.imports = with inputs.self.modules.homeManager; [
          sean
          neovim
          claude
          networkmanager
        ];
      };
    };

  flake.modules.homeManager.sean =
    { config, ... }:
    {
      imports = with inputs.self.modules.homeManager; [
        btop
        fastfetch
        git
        shell
        sops
        ssh
      ];

      home.stateVersion = "25.11";

      home.username = "sean";
      home.homeDirectory = "/home/${config.home.username}";

      programs.git.settings.user = {
        name = "sean tietz";
        email = "sean.tietz2@gmail.com";
      };
    };
}
