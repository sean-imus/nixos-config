{ ... }: {
  flake.modules.homeManager.alacritty = {
    programs.alacritty = {
      enable = true;
      settings = {
        env.TERM = "xterm-256color";
        font = {
          size = 9;
        };
        scrolling.multiplier = 5;
        selection.save_to_clipboard = true;
        window.opacity = 0.7;
      };
    };
  };
}
