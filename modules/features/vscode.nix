{ inputs, ... }:
{
  flake-file.inputs = {
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.modules.homeManager.vscode =
    { pkgs, config, ... }:
    let
      flakePath = config.home.homeDirectory + "/nixos-config";
      hostName = builtins.head (builtins.attrNames inputs.self.nixosConfigurations);
    in
    {
      programs.vscode = {
        enable = true;
        mutableExtensionsDir = false;
        package = pkgs.vscode.overrideAttrs (old: {
          postInstall = (old.postInstall or "") + ''
            for size in 16 24 32 48 64 96 128 256 512; do
              mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps
              ln -sf $out/share/icons/hicolor/1024x1024/apps/vscode.png \
                $out/share/icons/hicolor/''${size}x''${size}/apps/vscode.png
            done
          '';
        });
        profiles.default = {
          enableUpdateCheck = false;
          enableExtensionUpdateCheck = false;
          enableMcpIntegration = true;
          extensions = [
            pkgs.vscode-extensions.shd101wyy.markdown-preview-enhanced
            pkgs.vscode-extensions.bbenoist.nix
            pkgs.vscode-extensions.jnoortheen.nix-ide
            pkgs.vscode-extensions.leonardssh.vscord
            inputs.nix-vscode-extensions.extensions.${pkgs.stdenv.hostPlatform.system}.vscode-marketplace.mpmischitelli.gtk-css
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
                    "expr" = "(builtins.getFlake \"${flakePath}\").nixosConfigurations.${hostName}.options";
                  };
                  "home-manager" = {
                    "expr" =
                      "(builtins.getFlake \"${flakePath}\").nixosConfigurations.${hostName}.options.home-manager.users.type.getSubOptions []";
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
