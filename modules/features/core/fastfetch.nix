{ ... }:
{
  flake.modules.homeManager.core =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.fastfetch ];
      home.shellAliases.ff = "fastfetch";
    };
}
