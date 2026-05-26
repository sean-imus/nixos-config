{ inputs, ... }:
let
  monitorOutputs = {
    notebook = {
      "eDP-1" = {
        mode = {
          width = 1920;
          height = 1080;
          refresh = 60.0;
        };
        position = {
          x = 0;
          y = 0;
        };
      };
      "Iiyama North America PL2770H 0x0000011F" = {
        mode = {
          width = 1920;
          height = 1080;
          refresh = 144.0;
        };
        position = {
          x = -1920;
          y = 0;
        };
      };
      "Iiyama North America PL2770H 0x00000124" = {
        mode = {
          width = 1920;
          height = 1080;
          refresh = 143.998;
        };
        position = {
          x = -3840;
          y = 0;
        };
        focus-at-startup = true;
      };
      "Iiyama North America PLX2783H 1128255001580" = {
        mode = {
          width = 1920;
          height = 1080;
          refresh = 60.0;
        };
        position = {
          x = -5760;
          y = 0;
        };
      };
      "GIGA-BYTE TECHNOLOGY CO., LTD. M27U 23463B001145" = {
        mode = {
          width = 3840;
          height = 2160;
          refresh = 60.0;
        };
        position = {
          x = 0;
          y = -1440;
        };
        focus-at-startup = true;
      };
    };
    vm = {
      "Virtual-1" = {
        mode = {
          width = 1920;
          height = 1080;
          refresh = 60.0;
        };
        position = {
          x = 0;
          y = 0;
        };
      };
    };
    gaming-notebook = { };
  };
in
{
  flake.modules.nixos.sean =
    {
      pkgs,
      config,
      lib,
      ...
    }:
    {
      imports = with inputs.self.modules.nixos; [
        terminal
        browser
        btop
        fastfetch
        git
        shell
        sops
        ssh
        libreoffice
        vesktop
        opencode
        nixvim
        printing
        rdp-work
        localsend
        lockscreen
        bar
        niri
      ];

      options = {
        hostCfg.user.sean.gui.enable = lib.mkEnableOption "GUI desktop features";
        hostCfg.user.sean.dev.enable = lib.mkEnableOption "Development tools";
      };

      config = lib.mkMerge [
        {
          users.users.sean = {
            isNormalUser = true;
            description = "Sean Tietz";
            hashedPassword = "$6$T3H3jI/bBMNzxJHi$wmROphZMsgAahqu2dP/H6pquwXvAoKqJ7BIzvuHpI3BaBj7GSjY6EXaDxTZv21OfRKuE0WriJgdm4hyxMoWC8.";
            shell = pkgs.zsh;
            openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIogKvjjq6px3o3FU76R9/FmYYtYeIs0SrqzkaLfx+ru sean.tietz2@gmail.com"
            ];
            extraGroups = [
              "networkmanager"
              "wheel"
              "libvirtd"
            ];
          };

          programs.zsh.enable = true;

          home-manager.users.sean = {
            imports = [
              inputs.self.modules.homeManager.sean
            ];
          };
        }
        (lib.mkIf config.hostCfg.user.sean.gui.enable {
          userCfg.terminal.enable = true;
          userCfg.browser.enable = true;
          userCfg.bar.enable = true;
          userCfg.lockscreen.enable = true;
          userCfg.vesktop.enable = true;
          userCfg.opencode.enable = true;
          userCfg.localsend.enable = true;
          userCfg.libreoffice.enable = true;
          userCfg.printing.enable = true;
          userCfg.rdp-work.enable = true;
          userCfg.niri.enable = true;
        })
        (lib.mkIf config.hostCfg.user.sean.dev.enable {
          userCfg.nixvim.enable = true;
        })
        (lib.mkIf config.userCfg.niri.enable {
          home-manager.users.sean.programs.niri.settings = {
            outputs = monitorOutputs.${config.networking.hostName} or { };
            binds = {
              "Mod+T" = {
                action.spawn = "alacritty";
              };
              "Mod+B" = {
                action.spawn = "firefox";
              };
              "Mod+Ctrl+B" = {
                action.spawn = [
                  "alacritty"
                  "--class"
                  "bluetui"
                  "-e"
                  "bluetui"
                ];
              };
              "Mod+Ctrl+A" = {
                action.spawn = [
                  "alacritty"
                  "--class"
                  "wiremix"
                  "-e"
                  "wiremix"
                  "-v"
                  "playback"
                ];
              };
              "Mod+Ctrl+W" = {
                action.spawn = [
                  "alacritty"
                  "--class"
                  "netpala"
                  "-e"
                  "netpala"
                ];
              };
              "Mod+Shift+Space" = {
                action.spawn = [
                  "sh"
                  "-c"
                  "pkill waybar || true && waybar"
                ];
              };
              "Mod+Ctrl+Space" = {
                action.spawn = [
                  "sh"
                  "-c"
                  "pkill waybar"
                ];
              };
              "Mod+P" = {
                action.spawn = "power-toggle";
              };
              "Mod+Ctrl+Shift+C" = {
                action.spawn = "screencap";
              };
            };
          };
        })
      ];
    };

  flake.modules.homeManager.sean =
    { pkgs, config, ... }:
    {
      imports = with inputs.self.modules.homeManager; [
        userDefault
        btop
        fastfetch
        git
        shell
        sops
        ssh
      ];

      home.username = "sean";
      home.homeDirectory = "/home/${config.home.username}";

      programs.git.settings.user = {
        name = "sean tietz";
        email = "sean.tietz2@gmail.com";
      };

      home.packages = with pkgs; [
        dnsutils
        ripgrep
      ];
    };
}
