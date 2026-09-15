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
    colors = {
      bg = "#2d353b";
      "bg+" = "#343f44";
      border = "#7a8478";
      fg = "#d3c6aa";
      "fg+" = "#d3c6aa";
      header = "#83c092";
      hl = "#a7c080";
      "hl+" = "#a7c080";
      info = "#dbbc7f";
      marker = "#e67e80";
      pointer = "#d699b6";
      prompt = "#e67e80";
      spinner = "#a7c080";
    };
    defaultOptions = [
      "--height=40%"
      "--layout=reverse"
      "--border"
    ];
  };

  programs.zoxide = {
    enable = true;
    options = [ "--cmd=cd" ];
  };

  programs.nh = {
    enable = true;
    flake = "/home/sean/nixos-config";
  };

  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
  };

  programs.carapace.enable = true;

  programs.tealdeer = {
    enable = true;
    enableAutoUpdates = false;
    settings.updates.auto_update = true;
  };

  home.packages = with pkgs; [
    bat
    ncdu
  ];
}
