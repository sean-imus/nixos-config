{ pkgs, ... }:
let
  theme = import ../lib/theme.nix;
in
{
  manual.manpages.enable = false;

  programs = {
    fish = {
      enable = true;
      generateCompletions = false;
      functions.fish_greeting = "";
      shellAbbrs."-" = {
        position = "command";
        expansion = "tldr";
      };
      interactiveShellInit = ''
        if test -z "$DISPLAY"; and test -z "$WAYLAND_DISPLAY"; and test (tty) = "/dev/tty1"
          exec niri-session
        end
      '';
    };

    starship = {
      enable = true;
      enableFishIntegration = true;
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
      enableFishIntegration = true;
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

    nh = {
      enable = true;
      flake = "/home/sean/nixos-config";
    };

    eza = {
      enable = true;
      git = true;
      icons = "auto";
    };

    carapace.enable = true;

    tealdeer = {
      enable = true;
      enableAutoUpdates = false;
      settings.updates.auto_update = true;
    };
  };

  home = {
    shellAliases.rbu = "nix flake update && git add flake.lock && git commit -m 'chore(inputs): updated hashes'";
    packages = with pkgs; [
      bat
      ncdu
    ];
  };
}
