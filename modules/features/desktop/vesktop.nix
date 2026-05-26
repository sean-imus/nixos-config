{ inputs, lib, ... }:
{
  flake.modules.nixos.vesktop = { config, ... }: {
    options.userCfg.vesktop.enable = lib.mkEnableOption "Vesktop Discord client";
    config = lib.mkIf config.userCfg.vesktop.enable {
      home-manager.users.sean.imports = [ inputs.self.modules.homeManager.vesktop ];
    };
  };

  flake.modules.homeManager.vesktop = {
    programs.vesktop = {
      enable = true;
      settings = {
        discordBranch = "stable";
        tray = false;
        hardwareAcceleration = true;
      };
      vencord.settings = {
        autoUpdate = false;
        plugins = {
          AnonymiseFileNames.enabled = true;
          CrashHandler.enabled = true;
          PreviewMessage.enabled = true;
          NoBlockedMessages.enabled = true;
          ShikiCodeblocks.enabled = true;
          WebKeybinds.enabled = true;
          WebScreenShareFixes.enabled = true;
        };
      };
    };

    xdg.configFile."vesktop/state.json" = {
      text = ''{"firstLaunch":false}'';
      force = true;
    };
  };
}
