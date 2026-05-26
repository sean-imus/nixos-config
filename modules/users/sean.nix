{ inputs, lib, ... }:
{
  flake.modules.nixos.sean =
    { pkgs, config, ... }:
    {
      options.hostCfg.user.sean = {
        gui.enable = lib.mkEnableOption "GUI apps & desktop environment";
        dev.enable = lib.mkEnableOption "development tools";
      };

      imports = with inputs.self.modules.nixos; [
        localsend
      ];

      config = {
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
          ++ lib.optionals config.hostCfg.user.sean.gui.enable [
            inputs.self.modules.homeManager.terminal
            inputs.self.modules.homeManager.browser
            inputs.self.modules.homeManager.niri
            inputs.self.modules.homeManager.waybar
            inputs.self.modules.homeManager.lockscreen
            inputs.self.modules.homeManager.localsend
            inputs.self.modules.homeManager.libreoffice
            inputs.self.modules.homeManager.opencode
            inputs.self.modules.homeManager.vesktop
            inputs.self.modules.homeManager.printing
            inputs.self.modules.homeManager.rdp-work
          ]
          ++ lib.optionals config.hostCfg.user.sean.dev.enable [
            inputs.self.modules.homeManager.nixvim
            inputs.nixvim.homeModules.nixvim
          ];
        } // lib.optionalAttrs config.hostCfg.user.sean.gui.enable {
          niri.config.extraBinds = ''
            Mod+T            { spawn "alacritty"; }
            Mod+B            { spawn "firefox"; }
            Mod+Ctrl+B       { spawn-sh "alacritty --class bluetui -e bluetui"; }
            Mod+Ctrl+A       { spawn-sh "alacritty --class wiremix -e wiremix -v playback"; }
            Mod+Ctrl+W       { spawn-sh "alacritty --class netpala -e netpala"; }
            Mod+Shift+Space  { spawn-sh "pkill waybar || true && waybar"; }
            Mod+CTRL+Space   { spawn-sh "pkill waybar"; }
            Mod+P            { spawn "power-toggle"; }
            Mod+Ctrl+Shift+C { spawn-sh "screencap"; }
          '';
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
