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
      };
    };
  };
}
