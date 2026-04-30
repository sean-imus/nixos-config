{ ... }:

{
  nixosModule = { };

  homeManagerModule = {
    # Install Lazygit
    programs.lazygit.enable = true;

    # Setup Lazygit Alias
    home.shellAliases = {
      lg = "lazygit";
    };

    # Install Git
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
