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
        ]
        ++ lib.optionals config.userCfg.terminal.enable [ inputs.self.modules.homeManager.terminal ]
        ++ lib.optionals config.userCfg.browser.enable [ inputs.self.modules.homeManager.browser ]
        ++ lib.optionals config.userCfg.niri.enable [ inputs.self.modules.homeManager.niri ]
        ++ lib.optionals config.userCfg.bar.enable [ inputs.self.modules.homeManager.bar ]
        ++ lib.optionals config.userCfg.lockscreen.enable [ inputs.self.modules.homeManager.lockscreen ]
        ++ lib.optionals config.userCfg.localsend.enable [ inputs.self.modules.homeManager.localsend ]
        ++ lib.optionals config.userCfg.libreoffice.enable [ inputs.self.modules.homeManager.libreoffice ]
        ++ lib.optionals config.userCfg.opencode.enable [ inputs.self.modules.homeManager.opencode ]
        ++ lib.optionals config.userCfg.vesktop.enable [ inputs.self.modules.homeManager.vesktop ]
        ++ lib.optionals config.userCfg.printing.enable [ inputs.self.modules.homeManager.printing ]
        ++ lib.optionals config.userCfg.rdp-work.enable [ inputs.self.modules.homeManager.rdp-work ]
        ++ lib.optionals config.userCfg.nixvim.enable [
          inputs.self.modules.homeManager.nixvim
          inputs.nixvim.homeModules.nixvim
        ];
      }
      // lib.optionalAttrs config.userCfg.niri.enable {
        programs.niri.settings = {
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
      };
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
