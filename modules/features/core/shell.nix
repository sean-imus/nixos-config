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
          style = "bold #dbbc7f";
        };

        directory = {
          format = "([$path]($style) )";
          style = "bold #83c092";
          truncate_to_repo = false;
        };

        git_branch = {
          format = "[$branch ]($style)";
          style = "bold #d699b6";
        };

        git_status = {
          format = "([$all_status$ahead_behind]($style) )";
          style = "bold #e67e80";
        };

        character = {
          success_symbol = "[❯](bold #a7c080)";
          error_symbol = "[❯](bold #e67e80)";
        };

      };
    };

    programs.bat = {
      enable = true;
      config.theme = "base16";
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

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
