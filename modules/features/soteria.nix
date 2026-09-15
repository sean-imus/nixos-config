_:
let
  theme = import ../lib/theme.nix;
in
{
  xdg.configFile."soteria/style.css".text = ''
    @define-color ef_bg ${theme.hex theme.bg0};
    @define-color ef_bg_alt ${theme.hex theme.bg1};
    @define-color ef_fg ${theme.hex theme.fg};
    @define-color ef_grey ${theme.hex theme.grey0};
    @define-color ef_green ${theme.hex theme.green};

    window,
    window.background {
      background-color: @ef_bg;
      color: @ef_fg;
    }

    headerbar {
      background-color: @ef_bg_alt;
      color: @ef_fg;
    }

    label {
      color: @ef_fg;
    }

    entry {
      background-color: @ef_bg_alt;
      color: @ef_fg;
      border: 1px solid @ef_grey;
      border-radius: 6px;
      padding: 4px 8px;
    }

    entry:focus {
      border-color: @ef_green;
    }

    entry placeholder {
      color: @ef_grey;
    }

    button,
    dropdown button {
      background-color: @ef_bg_alt;
      color: @ef_fg;
      border: 1px solid @ef_grey;
      border-radius: 6px;
      padding: 4px 12px;
    }

    button:hover,
    dropdown button:hover {
      background-color: ${theme.hex theme.bg2};
      border-color: @ef_green;
    }

    button:active,
    button:checked {
      background-color: ${theme.hex theme.bg3};
    }

    popover {
      background-color: @ef_bg_alt;
      color: @ef_fg;
    }

    popover row:selected {
      background-color: @ef_green;
      color: @ef_bg;
    }
  '';
}
