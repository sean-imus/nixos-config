{ theme, shadowDesktopEntries, ... }:
{
  flake.modules = {
    nixos.shell = {
      programs.fish.generateCompletions = false;
    };

    homeManager.shell =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        programs = {
          fish = {
            enable = true;
            generateCompletions = false;
            functions.fish_greeting = "";
          };

          starship = {
            enable = true;
            settings = {
              add_newline = false;
              format = "$cmd_duration$directory$git_branch$git_status$character";

              cmd_duration = {
                min_time = 2000;
                format = "[($duration)]($style) ";
                style = "bold ${theme.hex theme.yellow}";
              };

              directory = {
                format = "([$path]($style) )";
                style = "bold ${theme.hex theme.aqua}";
                truncate_to_repo = false;
              };

              git_branch = {
                format = "[$branch ]($style)";
                style = "bold ${theme.hex theme.purple}";
              };

              git_status = {
                format = "([$all_status$ahead_behind]($style) )";
                style = "bold ${theme.hex theme.red}";
              };

              character = {
                success_symbol = "[❯](bold ${theme.hex theme.green})";
                error_symbol = "[❯](bold ${theme.hex theme.red})";
              };
            };
          };

          fzf = {
            enable = true;
            colors = {
              bg = theme.hex theme.bg0;
              "bg+" = theme.hex theme.bg1;
              border = theme.hex theme.grey0;
              fg = theme.hex theme.fg;
              "fg+" = theme.hex theme.fg;
              header = theme.hex theme.aqua;
              hl = theme.hex theme.green;
              "hl+" = theme.hex theme.green;
              info = theme.hex theme.yellow;
              marker = theme.hex theme.red;
              pointer = theme.hex theme.purple;
              prompt = theme.hex theme.red;
              spinner = theme.hex theme.green;
            };
            defaultOptions = [
              "--height=40%"
              "--layout=reverse"
              "--border"
            ];
          };

          zoxide = {
            enable = true;
            options = [ "--cmd=cd" ];
          };

          eza = {
            enable = true;
            git = true;
            icons = "auto";
          };

          carapace.enable = true;

          btop = {
            enable = true;
            settings = {
              update_ms = 1000;
              color_theme = "everforest-dark-medium";
            };
          };

          fastfetch.enable = true;

          tealdeer = {
            enable = true;
            enableAutoUpdates = false;
            settings.updates.auto_update = true;
          };
        };

        home = {
          shellAliases = {
            ff = "fastfetch";
          };
          packages = with pkgs; [
            bat
            ncdu
          ];
        };

        xdg.dataFile = shadowDesktopEntries pkgs pkgs.btop [ "btop" ];

        wayland.windowManager.niri.settings = {
          binds."Mod+Ctrl+T".spawn = [
            (lib.getExe config.programs.foot.package)
            "--app-id"
            "btop"
            "btop"
          ];

          _children = [
            {
              window-rule._children = [
                {
                  match._props.app-id = "^btop$";
                  open-floating = true;
                }
              ];
            }
          ];
        };
      };
  };
}
