{ pkgs, ... }:
let
  theme = import ../lib/theme.nix;
in
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
        --cc-bg: rgba(${theme.rgb.bg0}, 0.85);
        --noti-border-color: ${theme.hex theme.green};
        --noti-bg: ${theme.rgb.bg0};
        --noti-bg-alpha: 0.9;
        --noti-bg-darker: rgb(${theme.rgb.bg1});
        --noti-bg-hover: rgb(${theme.rgb.bg1});
        --noti-bg-focus: rgba(${theme.rgb.bg1}, 0.7);
        --noti-close-bg: rgb(${theme.rgb.bg1});
        --noti-close-bg-hover: rgb(${theme.rgb.red});
        --text-color: ${theme.hex theme.fg};
        --text-color-disabled: ${theme.hex theme.grey1};
        --bg-selected: ${theme.hex theme.green};
        --border: 2px solid ${theme.hex theme.green};
        --border-radius: 8px;
        --font-size-body: 11px;
        --font-size-summary: 11px;
      }

      * {
        font-family: "${theme.fontFamily}";
      }
    '';
  };

  home.packages = [ pkgs.libnotify ];
}
