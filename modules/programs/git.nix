{ ... }:
{
  flake.modules.homeManager.git = {
    programs.lazygit.enable = true;

    home.shellAliases = {
      lg = "lazygit";
    };

    programs.git = {
      enable = true;
      settings = {
        user = {
          Name = "sean tietz";
          Email = "sean.tietz2@gmail.com";
        };
      };
    };
  };
}
