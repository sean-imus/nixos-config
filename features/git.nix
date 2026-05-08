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
          Name = "sean tietz";
          Email = "sean.tietz2@gmail.com";
        };
      };
    };
  };
}
