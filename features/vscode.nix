{ pkgs, ... }:

{
  nixosModule = { };

  homeManagerModule = {
    # Install VScode
    programs.vscode = {
      enable = true;
      mutableExtensionsDir = false;
      profiles.default = {
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;
        enableMcpIntegration = true;
        extensions = [
          pkgs.vscode-extensions.shd101wyy.markdown-preview-enhanced
          pkgs.vscode-extensions.bbenoist.nix
          pkgs.vscode-extensions.jnoortheen.nix-ide
        ];
        userSettings = {
          "files.autoSave" = "afterDelay";
          "editor.minimap.enabled" = false;
        };
      };
    };
  };
}
