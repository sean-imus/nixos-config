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
          "files.autoSave" = "onFocusChange";
          "editor.minimap.enabled" = false;
          "editor.formatOnSave" = true;
          "git.enableSmartCommit" = true;
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nixd";
          "nix.serverSettings" = {
            "nixd" = {
              "formatting" = {
                "command" = [ "nixfmt" ];
              };
              "options" = {
                "nixos" = {
                  "expr" = "(builtins.getFlake \"/home/sean/nixos-config\").nixosConfigurations.nixos.options";
                };
                "home-manager" = {
                  "expr" =
                    "(builtins.getFlake \"/home/sean/nixos-config\").nixosConfigurations.nixos.options.home-manager.users.type.getSubOptions []";
                };
              };
            };
          };
          "[nix]" = {
            "editor.defaultFormatter" = "jnoortheen.nix-ide";
          };
        };
      };
    };
  };
}
