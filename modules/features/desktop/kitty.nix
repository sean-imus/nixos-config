{ ... }:
{
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "JetBrainsMono Nerd Font";
      font_size = 10;
      wheel_scroll_multiplier = 5;
      cursor_trail = 6;
      cursor_trail_delay = 0.01;
      cursor_trail_duration = 0.4;
    };
  };
}
