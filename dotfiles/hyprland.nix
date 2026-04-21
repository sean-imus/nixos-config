{ ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      $mainMod = SUPER

      # Applications
      bind = $mainMod, RETURN, exec, alacritty
      bind = $mainMod SHIFT, B, exec, chromium

      # Functionality
      bind = $mainMod, W, killactive,
      bind = $mainMod, M, exit,
    '';
  };
}
