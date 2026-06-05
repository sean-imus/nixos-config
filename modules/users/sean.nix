{ inputs, ... }:
{
  flake.modules.nixos.sean =
    { pkgs, ... }:
    {
      config = {
        users.users.sean = {
          isNormalUser = true;
          description = "Sean Tietz";
          hashedPassword = "$6$T3H3jI/bBMNzxJHi$wmROphZMsgAahqu2dP/H6pquwXvAoKqJ7BIzvuHpI3BaBj7GSjY6EXaDxTZv21OfRKuE0WriJgdm4hyxMoWC8.";
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

        #TODO Remove since it doenst make sense here, just needed it for a project here
        users.groups.adbusers = { };
        environment.systemPackages = [ pkgs.android-tools ];

        home-manager.users.sean.imports = with inputs.self.modules.homeManager; [
          sean
          neovim
          opencode
        ];
      };
    };

  flake.modules.homeManager.sean =
    { config, ... }:
    {
      imports = with inputs.self.modules.homeManager; [
        userDefault
        btop
        fastfetch
        git
        shell
        sops
        ssh
      ];

      home.username = "sean";
      home.homeDirectory = "/home/${config.home.username}";

      programs.git.settings.user = {
        name = "sean tietz";
        email = "sean.tietz2@gmail.com";
      };
    };
}
