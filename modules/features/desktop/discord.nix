{ ... }:
{
  flake.modules.nixos.desktop = {
    # vesktop build dep; only used in a sandboxed build environment, not runtime
    nixpkgs.config.permittedInsecurePackages = [ "pnpm-10.29.2" ];
  };

  flake.modules.homeManager.desktop = {
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
