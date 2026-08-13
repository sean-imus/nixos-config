{ ... }:
{
  flake.modules.homeManager.core = {
    programs.fastfetch.enable = true;
    home.shellAliases.ff = "fastfetch";
  };
}
