{ ... }:

{
  nixosModule = { };

  homeManagerModule = {
    # Install VScode
    programs.vscode = {
      enable = true;
    };
  };
}
