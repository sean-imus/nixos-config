{ ... }:

{
  nixosModule = { };

  homeManagerModule = {
    programs.starship = {
      enable = true;
      enableZshIntegration = true;

      settings = {
        add_newline = false;
        format = "$nix_shell\${custom.cwd}$git_branch$git_status$character";

        directory = {
          disabled = true;
        };

        custom.cwd = {
          command = "pwd | sed \"s#^$HOME#~#\"";
          when = "true";
          format = "[($output)]($style) ";
          style = "bold cyan";
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

        nix_shell = {
          format = "[$symbol$state]($style) ";
          symbol = "nix-shell";
          impure_msg = "";
          pure_msg = "";
          unknown_msg = "";
          style = "bold cyan";
          heuristic = true;
        };
      };
    };

    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      enableCompletion = true;
      autocd = true;
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
