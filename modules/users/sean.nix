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
          extraGroups = [
            "networkmanager"
            "wheel"
            "libvirtd"
            "video"
            "adbusers"
          ];
        };

        users.groups.adbusers = { };
        home-manager.users.sean.imports = with inputs.self.modules.homeManager; [
          sean
          neovim
          claude
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
