{ pkgs, ... }:

{
  nixosModule = { };

  homeManagerModule = {
    programs.vscode = {
      enable = true;
    };
  };
}
