{ inputs, ... }:
{
  den.aspects.comma.homeManager = {
    imports = [ inputs.nix-index-database.homeModules.default ];

    programs.nix-index.enableFishIntegration = false;
    programs.nix-index-database.comma.enable = true;
  };
}
