{ inputs, ... }:
{
  flake.modules.nixos.sean-headless =
    { pkgs, ... }:
    {
      users.users.sean = {
        isNormalUser = true;
        description = "Sean Tietz";
        hashedPassword = "$6$T3H3jI/bBMNzxJHi$wmROphZMsgAahqu2dP/H6pquwXvAoKqJ7BIzvuHpI3BaBj7GSjY6EXaDxTZv21OfRKuE0WriJgdm4hyxMoWC8.";
        shell = pkgs.zsh;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIogKvjjq6px3o3FU76R9/FmYYtYeIs0SrqzkaLfx+ru sean.tietz2@gmail.com"
        ];
        extraGroups = [
          "wheel"
          "networkmanager"
        ];
      };

      programs.zsh.enable = true;

      home-manager.users.sean = {
        imports = [
          inputs.self.modules.homeManager.sean-headless
        ];
      };
    };

  flake.modules.homeManager.sean-headless =
    { pkgs, config, ... }:
    {
      imports = with inputs.self.modules.homeManager; [
        userDefault
        btop
        shell
        sops
        ssh
      ];

      home.username = "sean";
      home.homeDirectory = "/home/${config.home.username}";

      home.packages = with pkgs; [
        dnsutils
      ];
    };
}
