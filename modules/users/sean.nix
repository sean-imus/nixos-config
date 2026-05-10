{ inputs, ... }:
{
  flake.modules.homeManager.sean =
    { pkgs, config, ... }:
    {
      imports = with inputs.self.modules.homeManager; [
        alacritty
        btop
        firefox
        git
        mcp
        neovim
        niri
        opencode
        printing
        rdp-work
        shell
        ssh
        vesktop
        vscode
      ];

      home.username = "sean";
      home.homeDirectory = "/home/${config.home.username}";

      programs.git = {
        settings.user = {
          name = "sean tietz";
          email = "sean.tietz2@gmail.com";
        };
      };

      programs.firefox.profiles.${config.home.username}.bookmarks = {
        force = true;
        settings = [
          {
            toolbar = true;
            bookmarks = [
              {
                name = "NixOS";
                bookmarks = [
                  {
                    name = "NixOS Search";
                    url = "https://search.nixos.org/options?channel=unstable&include_home_manager_options=1&include_modular_service_options=1&include_nixos_options=1";
                  }
                  {
                    name = "Niri Wiki";
                    url = "https://niri-wm.github.io/niri/";
                  }
                ];
              }
              {
                name = "Work";
                bookmarks = [
                  {
                    name = "Outlook";
                    url = "https://outlook.cloud.microsoft/mail/";
                  }
                  {
                    name = "Teams";
                    url = "https://teams.cloud.microsoft/";
                  }
                  {
                    name = "To-Do";
                    url = "https://app.fizzy.do/6172759/boards/03fqfadkang7940o21lqrzl2e/columns/stream";
                  }
                  {
                    name = "Copilot";
                    url = "https://m365.cloud.microsoft/chat";
                  }
                  {
                    name = "Microsoft Admin Center";
                    url = "https://admin.cloud.microsoft/";
                  }
                  {
                    name = "Sophos Admin Center";
                    url = "https://central.sophos.com/manage/overview/dashboard";
                  }
                  {
                    name = "Swyx Control Center";
                    url = "https://www.swyxon.com/ControlCenter";
                  }
                  {
                    name = "E-Mail Live Tracking";
                    url = "https://ms.hees.de/email_security/email_livetracking";
                  }
                ];
              }
              {
                name = "Tools";
                bookmarks = [
                  {
                    name = "Photo Editor";
                    url = "https://www.photopea.com/";
                  }
                  {
                    name = "Graph Maker";
                    url = "https://app.diagrams.net/";
                  }
                ];
              }
            ];
          }
        ];
      };

      home.packages = with pkgs; [
        libreoffice
        spotify
        nixfmt-tree
        nixfmt
        nixd
      ];

      home.stateVersion = "25.11";
    };
}
