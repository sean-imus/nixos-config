{ ... }:
{
  flake.modules.homeManager.git = {
    programs.lazygit.enable = true;

    home.shellAliases = {
      lg = "lazygit";
    };

    programs.git.enable = true;
  };
}
