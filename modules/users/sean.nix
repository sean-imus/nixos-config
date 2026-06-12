{ inputs, ... }:
{
  flake.modules.nixos.sean =
    { pkgs, ... }:
    {
      config = {
        users.users.sean = {
          isNormalUser = true;
          description = "Sean Tietz";
          hashedPassword = "$y$j9T$JRaDh99DoyOB47QI7Imjg0$9lMQ/jkdQpE3UXC338HsTqbhiI4XuZLK9iEy0yxTXYC";
          shell = pkgs.zsh;
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIogKvjjq6px3o3FU76R9/FmYYtYeIs0SrqzkaLfx+ru sean.tietz2@gmail.com"
          ];
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
