{ lib, ... }:
{
  flake.modules.nixos.vesktop = {
    options.userCfg.vesktop.enable = lib.mkEnableOption "Vesktop Discord client";
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
