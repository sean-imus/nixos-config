{
  lib,
  pkgs,
  theme,
  ...
}:
let
  fg = c: { fg = theme.hex theme.${c}; };
  fill = c: {
    fg = theme.hex theme.${c};
    bg = theme.hex theme.${c};
  };
  badge = fgc: bgc: {
    fg = theme.hex theme.${fgc};
    bg = theme.hex theme.${bgc};
    bold = true;
  };
  accent = fg "blue";
  syntaxScopes = [
    {
      scope = "comment";
      colour = "grey0";
    }
    {
      scope = "string";
      colour = "aqua";
    }
    {
      scope = "constant";
      colour = "purple";
    }
    {
      scope = "keyword, storage";
      colour = "red";
    }
    {
      scope = "keyword.operator";
      colour = "orange";
    }
    {
      scope = "entity.name.function, support.function";
      colour = "green";
    }
    {
      scope = "entity.name.type, entity.name.class, support.type, support.class";
      colour = "yellow";
    }
    {
      scope = "entity.name.tag";
      colour = "red";
    }
    {
      scope = "entity.other.attribute-name";
      colour = "yellow";
    }
    {
      scope = "markup.heading";
      colour = "orange";
    }
    {
      scope = "invalid";
      colour = "red";
    }
  ];
  syntaxTheme = pkgs.writeText "everforest.tmTheme" (
    lib.generators.toPlist { } {
      name = "Everforest";
      settings = [
        {
          settings = {
            background = theme.hex theme.bg0;
            foreground = theme.hex theme.fg;
            caret = theme.hex theme.fg;
            selection = theme.hex theme.bg3;
            lineHighlight = theme.hex theme.bg2;
          };
        }
      ]
      ++ map (
        { scope, colour }:
        {
          inherit scope;
          settings.foreground = theme.hex theme.${colour};
        }
      ) syntaxScopes;
    }
  );
in
{
  programs.yazi = {
    enable = true;

    theme = {
      mgr = {
        cwd = accent;
        find_keyword = (fg "yellow") // {
          bold = true;
          italic = true;
          underline = true;
        };
        find_position = {
          fg = theme.hex theme.purple;
          bg = "reset";
          bold = true;
          italic = true;
        };
        marker_copied = fill "green";
        marker_cut = fill "red";
        marker_marked = fill "blue";
        marker_selected = fill "yellow";
        count_copied = badge "bg1" "green";
        count_cut = badge "bg1" "red";
        count_selected = badge "bg1" "yellow";
        border_symbol = "│";
        border_style = fg "bg4";
        syntect_theme = "${syntaxTheme}";
      };
      tabs = {
        active = badge "bg1" "green";
        inactive = (fg "green") // {
          bg = theme.hex theme.bg2;
        };
      };
      mode = {
        normal_main = badge "bg2" "green";
        normal_alt = badge "blue" "bg4";
        select_main = badge "bg2" "red";
        select_alt = badge "blue" "bg4";
        unset_main = badge "bg2" "blue";
        unset_alt = badge "blue" "bg4";
      };
      status = {
        perm_sep = fg "bg0";
        perm_type = fg "green";
        perm_read = fg "yellow";
        perm_write = fg "red";
        perm_exec = fg "blue";
        progress_label.bold = true;
        progress_normal = (fg "blue") // {
          bg = theme.hex theme.bg0;
        };
        progress_error = (fg "red") // {
          bg = theme.hex theme.bg0;
        };
      };
      pick = {
        border = accent;
        active = (fg "purple") // {
          bold = true;
        };
      };
      input = {
        border = accent;
        selected.reversed = true;
      };
      cmp.border = accent;
      tasks = {
        border = accent;
        hovered = (fg "purple") // {
          underline = true;
        };
      };
      which = {
        mask.bg = theme.hex theme.bg0;
        cand = accent;
        rest = fg "grey1";
        desc = fg "purple";
        separator = "  ";
        separator_style = fg "grey1";
      };
      help = {
        on = accent;
        run = fg "purple";
        hovered = {
          reversed = true;
          bold = true;
        };
        footer = {
          fg = theme.hex theme.bg0;
          bg = theme.hex theme.fg;
        };
      };
      spot = {
        border = accent;
        title = accent;
        tbl_col = accent;
        tbl_cell = (fg "yellow") // {
          reversed = true;
        };
      };
      notify = {
        title_info = fg "green";
        title_warn = fg "yellow";
        title_error = fg "red";
      };
      filetype.rules = [
        {
          mime = "image/*";
          fg = theme.hex theme.blue;
        }
        {
          mime = "{audio,video}/*";
          fg = theme.hex theme.purple;
        }
        {
          mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}";
          fg = theme.hex theme.red;
        }
        {
          mime = "application/{pdf,doc,rtf}";
          fg = theme.hex theme.blue;
        }
        {
          mime = "vfs/{absent,stale}";
          fg = theme.hex theme.bg4;
        }
        {
          url = "*";
          fg = theme.hex theme.aqua;
        }
        {
          url = "*/";
          fg = theme.hex theme.green;
        }
      ];
    };

    settings = {
      mgr = {
        sort_by = "natural";
        linemode = "size";
      };
      preview.wrap = "yes";
    };

    keymap = {
      mgr.append_keymap = [
        {
          on = [
            "g"
            "r"
          ];
          run = "cd --interactive";
          desc = "Jump to a path";
        }
        {
          on = [
            "g"
            "d"
          ];
          run = "cd ~/Downloads";
          desc = "Go to Downloads";
        }
        {
          on = [
            "g"
            "n"
          ];
          run = "cd ~/nixos-config";
          desc = "Go to nixos-config";
        }
        {
          on = [
            "g"
            "."
          ];
          run = "cd ~/.config";
          desc = "Go to ~/.config";
        }
      ];
    };

    extraPackages = with pkgs; [
      _7zz
      chafa
      fd
      ffmpeg
      file
      imagemagick
      jq
      poppler-utils
      resvg
      ripgrep
    ];
  };
}
