{ ... }:
let
  startPage = "file://${./_start-page.html}";
in
{
  flake.modules.homeManager.browser =
    { pkgs, config, ... }:
    {
      programs.qutebrowser = {
        enable = true;
        package = pkgs.qutebrowser;

        searchEngines = {
          DEFAULT = "https://duckduckgo.com/?q={}";
          ns = "https://search.nixos.org/options?channel=unstable&include_home_manager_options=1&include_modular_service_options=1&include_nixos_options=1&query={}";
          np = "https://search.nixos.org/packages?channel=unstable&query={}";
          gh = "https://github.com/search?q={}&type=repositories";
        };

        quickmarks = {
          oo = "https://outlook.cloud.microsoft/mail/";
          tt = "https://teams.cloud.microsoft/";
          td = "https://app.fizzy.do/6172759/boards/03fqfadkang7940o21lqrzl2e/columns/stream";
          cp = "https://m365.cloud.microsoft/chat";
          ma = "https://admin.cloud.microsoft/";
          sa = "https://central.sophos.com/manage/overview/dashboard";
          sw = "https://www.swyxon.com/ControlCenter";
          em = "https://ms.hees.de/email_security/email_livetracking";
          eg = "https://mein.einfachgast.de/live";
          pe = "https://www.photopea.com/";
          br = "https://www.remove.bg/";
          gm = "https://app.diagrams.net/";
        };

        settings = {
          url = {
            start_pages = [ startPage ];
            default_page = startPage;
            open_base_url = true;
          };

          content = {
            autoplay = false;
            notifications.enabled = false;
            javascript.clipboard = "access-paste";
            blocking = {
              enabled = true;
              method = "both";
              adblock.lists = [
                "https://easylist.to/easylist/easylist.txt"
                "https://easylist.to/easylist/easyprivacy.txt"
                "https://easylist.to/easylistgermany/easylistgermany.txt"
              ];
              hosts.lists = [
                "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
              ];
            };
            pdfjs = true;
          };

          downloads = {
            location = {
              directory = config.home.homeDirectory;
              prompt = true;
            };
            position = "bottom";
            remove_finished = 3000;
          };

          editor.command = [
            "alacritty"
            "--class"
            "editor"
            "-e"
            "nvim"
            "{file}"
          ];

          tabs = {
            position = "top";
            show = "multiple";
            title.format = "{audio}{index}: {current_title}";
            favicons.show = "never";
            indicator.width = 0;
          };

          statusbar = {
            show = "in-mode";
            widgets = [
              "keypress"
              "url"
              "scroll"
              "history"
              "tabs"
            ];
          };

          scrolling.smooth = false;

          fonts = {
            default_family = "JetBrainsMono Nerd Font";
            default_size = "10pt";
          };

          colors = {
            webpage.darkmode.enabled = true;
            webpage.preferred_color_scheme = "dark";
          };

          hints = {
            chars = "asdfghjklqwertyuiopzxcvbnm";
            uppercase = false;
            scatter = true;
          };

          completion = {
            height = "40%";
            scrollbar.width = 0;
            show = "auto";
          };

          session.lazy_restore = true;

          keyhint.delay = 500;

          messages.timeout = 3000;

          confirm_quit = [ "downloads" ];
        };

        keyBindings = {
          normal = {
            "<Ctrl+Shift+J>" = "tab-move +";
            "<Ctrl+Shift+K>" = "tab-move -";
            "xb" = "config-cycle statusbar.show always in-mode ;; config-cycle tabs.show always multiple";
            "xh" = "config-cycle tabs.position left top";
            "j" = "cmd-run-with-count 3 scroll down";
            "k" = "cmd-run-with-count 3 scroll up";
          };
          insert = {
            "<Ctrl+e>" = "edit-text";
          };
        };

        extraConfig = ''
          config.bind("M", "hint links spawn mpv {hint-url}")
          config.bind(";M", "hint --rapid links spawn mpv {hint-url}")
        '';
      };
    };
}
