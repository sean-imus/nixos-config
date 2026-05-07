{ ... }:

{
  nixosModule = { };

  homeManagerModule = {
    programs.vesktop = {
      enable = true;
      settings = {
        discordBranch = "stable";
        tray = false;
        autoStartMinimized = false;
        arRPC = true;
        firstLaunch = false;
        linuxAutoStartEnabled = false;
        checkUpdates = false;
        hardwareAcceleration = true;
      };
      vencord.settings = {
        autoUpdate = false;
        plugins = {
          AnonymiseFileNames.enabled = true;
          CrashHandler.enabled = true;
          PreviewMessage.enabled = true;
          petpet.enabled = true;
          ShikiCodeblocks.enabled = true;
          WebKeybinds.enabled = true;
          WebScreenShareFixes.enabled = true;
        };
      };
    };
  };
}
