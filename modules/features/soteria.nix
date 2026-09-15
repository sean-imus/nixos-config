{ ... }:
{
  xdg.configFile."soteria/style.css".text = ''
    @define-color ef_bg #2d353b;
    @define-color ef_bg_alt #343f44;
    @define-color ef_fg #d3c6aa;
    @define-color ef_grey #7a8478;
    @define-color ef_green #a7c080;

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
      background-color: #3d484d;
      border-color: @ef_green;
    }

    button:active,
    button:checked {
      background-color: #475258;
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
