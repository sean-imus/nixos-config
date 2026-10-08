{ inputs, ... }:
{
  flake.modules.nixos.sean =
    { pkgs, ... }:
    {
      imports = [ inputs.home-manager.nixosModules.home-manager ];

      users = {
        mutableUsers = false;

        users.sean = {
          isNormalUser = true;
          hashedPasswordFile = "/home/sean/.secrets/password.txt";
          extraGroups = [
            "wheel"
            "video"
            "audio"
            "networkmanager"
            "dialout"
          ];
          shell = pkgs.fish;
        };
      };

      programs.fish.enable = true;

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "bak";

        users.sean.home.stateVersion = "26.11";
      };
    };
}
