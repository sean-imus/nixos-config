{ pkgs, ... }:
{
  programs.fish = {
    enable = true;
    functions.fish_greeting = "";
    interactiveShellInit = ''
      if test -z "$DISPLAY"; and test -z "$WAYLAND_DISPLAY"; and test (tty) = "/dev/tty1"
        exec niri-session
      end
    '';
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
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

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  home.packages = with pkgs; [
    bat
    ncdu
    tldr
  ];
}
