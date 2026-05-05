{ ... }:

{
  nixosModule = { };

  homeManagerModule = {
    programs.starship = {
      enable = true;
      enableBashIntegration = true;

      settings = {
        add_newline = false;
        format = "$nix_shell$nix_depth$directory$git_branch$git_status$character";

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
          symbol = "nix-shell";
          impure_msg = "";
          pure_msg = "";
          unknown_msg = "";
          style = "bold cyan";
          heuristic = true;
        };
      };
    };
  };
}
