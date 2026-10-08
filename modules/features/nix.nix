{ inputs, ... }:
{
  flake.modules = {
    nixos.nix = {
      nix = {
        channel.enable = false;
        daemonCPUSchedPolicy = "idle";
        daemonIOSchedClass = "idle";
        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 3d";
        };
        optimise = {
          automatic = true;
          dates = "weekly";
        };
        settings = {
          download-buffer-size = 134217728;
          warn-dirty = false;
          fallback = true;
          connect-timeout = 5;
          trusted-users = [
            "root"
            "@wheel"
          ];
          experimental-features = [
            "nix-command"
            "flakes"
          ];
        };
      };
    };

    homeManager.nix =
      { config, ... }:
      {
        imports = [ inputs.nix-index-database.homeModules.default ];

        programs = {
          nh = {
            enable = true;
            flake = "${config.home.homeDirectory}/nixos-config";
          };

          nix-index-database.comma.enable = true;
          nix-index.enableFishIntegration = false;
        };

        home.shellAliases.rbu = "nix flake update && git commit flake.lock -m 'chore(inputs): updated hashes'";
      };
  };
}
