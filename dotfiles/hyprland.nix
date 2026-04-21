{ ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      bindd = SHIFT, RETURN, Terminal, exec, alacritty
      bindd = SHIFT, B, Browser, exec, chromium
    '';
  };
}
