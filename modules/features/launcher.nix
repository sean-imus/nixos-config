{ pkgs, ... }:
let
  withAlpha = hex: hex + "ff";
in
{
  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        dpi-aware = false;
        namespace = "fuzzel";
        sort-result = false;
        icons-enabled = false;
      };
      colors = {
        background = withAlpha "2d353b";
        text = withAlpha "d3c6aa";
        prompt = withAlpha "7a8478";
        input = withAlpha "d3c6aa";
        match = withAlpha "a7c080";
        selection = "a7c08044";
        selection-text = withAlpha "d3c6aa";
        selection-match = withAlpha "a7c080";
        border = withAlpha "a7c080";
      };
      border = {
        width = 2;
        radius = 0;
      };
    };
  };

  programs.anyrun = {
    enable = true;
    config = {
      x.fraction = 0.5;
      y.fraction = 0.25;
      width.fraction = 0.35;
      hidePluginInfo = true;
      closeOnClick = true;
      showResultsImmediately = true;
      maxEntries = 8;
      plugins = [
        "${pkgs.anyrun}/lib/libapplications.so"
        "${pkgs.anyrun}/lib/libnix_run.so"
        "${pkgs.anyrun}/lib/libshell.so"
        "${pkgs.anyrun}/lib/libsymbols.so"
        "${pkgs.anyrun}/lib/libwebsearch.so"
      ];
    };

    extraCss = ''
      @define-color accent #a7c080;
      @define-color bg-color rgba(45, 53, 59, 0.95);
      @define-color fg-color #d3c6aa;
      @define-color desc-color #859289;

      window {
        background: transparent;
      }

      box.main {
        padding: 6px;
        margin: 10px;
        border-radius: 8px;
        border: 2px solid @accent;
        background-color: @bg-color;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.4);
        animation: fade 150ms ease-out;
      }

      text {
        min-height: 30px;
        padding: 5px;
        border-radius: 5px;
        background: transparent;
        color: @fg-color;
      }

      .matches {
        background-color: transparent;
        border-radius: 8px;
      }

      box.plugin.info {
        min-width: 200px;
      }

      list.plugin {
        background-color: transparent;
      }

      label.match {
        color: @fg-color;
      }

      label.match.description {
        font-size: 10px;
        color: @desc-color;
      }

      label.plugin.info {
        font-size: 14px;
        color: @fg-color;
      }

      .match {
        background: transparent;
      }

      .match:selected {
        border-left: 4px solid @accent;
        background: rgba(167, 192, 128, 0.15);
        animation: fade 100ms linear;
      }

      @keyframes fade {
        0% {
          opacity: 0;
        }

        100% {
          opacity: 1;
        }
      }
    '';
  };
}
