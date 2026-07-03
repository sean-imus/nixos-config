{ ... }:
{
  flake.modules.homeManager.core =
    { ... }:
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
      };
    };
}
