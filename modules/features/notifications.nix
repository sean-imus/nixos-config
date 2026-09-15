{ pkgs, ... }:
{
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "top";
      layer-shell = true;
      cssPriority = "application";
      control-center-width = 380;
      control-center-height = 600;
      control-center-margin-top = 4;
      control-center-margin-bottom = 4;
      control-center-margin-right = 4;
      control-center-margin-left = 4;
      notification-icon-size = 48;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      notification-window-width = 340;
      timeout = 8000;
      timeout-low = 4000;
      timeout-critical = 0;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 250;
      hide-on-clear = false;
      hide-on-action = true;
      notification-grouping = true;
    };

    style = ''
      :root {
        --cc-bg: rgba(45, 53, 59, 0.85);
        --noti-border-color: #a7c080;
        --noti-bg: 45, 53, 59;
        --noti-bg-alpha: 0.9;
        --noti-bg-darker: rgb(52, 63, 68);
        --noti-bg-hover: rgb(52, 63, 68);
        --noti-bg-focus: rgba(52, 63, 68, 0.7);
        --noti-close-bg: rgb(52, 63, 68);
        --noti-close-bg-hover: rgb(230, 126, 128);
        --text-color: #d3c6aa;
        --text-color-disabled: #859289;
        --bg-selected: #a7c080;
        --border: 2px solid #a7c080;
        --border-radius: 8px;
      }
    '';
  };

  home.packages = [ pkgs.libnotify ];
}
