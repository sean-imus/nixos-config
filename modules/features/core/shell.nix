{ ... }:
{
  flake.modules.homeManager.shell = {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        add_newline = false;
        format = "$cmd_duration$directory$git_branch$git_status$character";

        cmd_duration = {
          min_time = 2000;
          format = "[($duration)]($style) ";
          style = "bold yellow";
        };

        directory = {
          format = "([$path]($style) )";
          style = "bold cyan";
          truncate_to_repo = false;
        };

        git_branch = {
          format = "[$branch ]($style)";
          style = "bold purple";
        };

        git_status = {
          format = "([$all_status$ahead_behind]($style) )";
          style = "bold red";
        };

        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
        };

      };
    };

    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      shellAliases = {
        cl = "clear";
      };
      history = {
        size = 10000;
        save = 10000;
        share = true;
        ignoreAllDups = true;
        extended = true;
      };

    };
  };
}
