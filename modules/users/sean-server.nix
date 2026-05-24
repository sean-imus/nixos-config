{ inputs, ... }:
{
  flake.modules.nixos.sean-server =
    { pkgs, ... }:
    {
      users.users.sean = {
        isNormalUser = true;
        description = "Sean Tietz";
        hashedPassword = "$6$T3H3jI/bBMNzxJHi$wmROphZMsgAahqu2dP/H6pquwXvAoKqJ7BIzvuHpI3BaBj7GSjY6EXaDxTZv21OfRKuE0WriJgdm4hyxMoWC8.";
        shell = pkgs.zsh;
        extraGroups = [
          "wheel"
        ];
      };

      programs.zsh.enable = true;

      home-manager.users.sean = {
        imports = [
          inputs.self.modules.homeManager.sean-server
        ];
      };
    };

  flake.modules.homeManager.sean-server =
    { pkgs, config, ... }:
    {
      imports = with inputs.self.modules.homeManager; [
        userDefault
        btop
        git
        shell
        sops
        ssh
      ];

      home.username = "sean";
      home.homeDirectory = "/home/${config.home.username}";

      programs.git = {
        settings.user = {
          name = "sean tietz";
          email = "sean.tietz2@gmail.com";
        };
      };

      home.packages = with pkgs; [
        dnsutils
        ripgrep
      ];
    };
}
