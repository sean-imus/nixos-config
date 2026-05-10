{ ... }: {
  flake.modules.homeManager.vscode = { pkgs, config, ... }: let
    flakePath = config.home.homeDirectory + "/nixos-config";
  in {
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
          pkgs.vscode-extensions.leonardssh.vscord
          pkgs.nix-vscode-extensions.vscode-marketplace.mpmischitelli.gtk-css
        ];
        userSettings = {
          "files.autoSave" = "onFocusChange";
          "editor.minimap.enabled" = false;
          "editor.formatOnSave" = true;
          "git.enableSmartCommit" = true;
          "git.confirmSync" = false;
          "git.autofetch" = true;
          "files.associations" = {
            "*.css" = "gtk-css";
          };
          "nix.enableLanguageServer" = true;
          "nix.serverPath" = "nixd";
          "nix.serverSettings" = {
            "nixd" = {
              "formatting" = {
                "command" = [ "nixfmt" ];
              };
              "options" = {
                "nixos" = {
                  "expr" = "(builtins.getFlake \"${flakePath}\").nixosConfigurations.nixos.options";
                };
                "home-manager" = {
                  "expr" =
                    "(builtins.getFlake \"${flakePath}\").nixosConfigurations.nixos.options.home-manager.users.type.getSubOptions []";
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
