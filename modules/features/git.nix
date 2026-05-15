{ ... }:
{
  flake.modules.homeManager.git = {
    programs.lazygit = {
      enable = true;
      settings.disableStartupPopups = true;
    };

    home.shellAliases = {
      lg = "lazygit";
    };

    programs.git.enable = true;
  };
}
