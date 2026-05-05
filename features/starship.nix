{ ... }:

{
  nixosModule = { };

  homeManagerModule = {
    programs.starship = {
      enable = true;
      enableBashIntegration = true;

      settings = {
        add_newline = false;
        format = "$nix_shell$directory$git_branch$git_status$character";

        directory = {
          truncation_length = 3;
          truncation_symbol = ".../";
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
          symbol = "Nix ";
          impure_msg = "impure";
          pure_msg = "pure";
          unknown_msg = "unknown";
          style = "bold cyan";
        };
      };
    };
  };
}
