{ ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      $mainMod = RIGHTALT

      bind = $mainMod, RETURN, exec, alacritty
      bind = $mainMod SHIFT, B, exec, chromium
    '';
  };
}
