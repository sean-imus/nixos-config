{ ... }:

{
  nixosModule = { };

  homeManagerModule = {
    # Install Lazygit
    programs.lazygit.enable = true;

    # Setup Lazygit alias
    home.shellAliases = {
      lg = "lazygit";
    };

    # Install git
    programs.git = {
      enable = true;
      settings = {
        user = {
          Name = "Sean Tietz";
          Email = "sean.tietz2@gmail.com";
        };
      };
    };
  };
}
