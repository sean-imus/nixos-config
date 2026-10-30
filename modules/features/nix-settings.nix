{
  den.aspects.nix-settings.nixos = {
    nix = {
      channel.enable = false;
      daemonCPUSchedPolicy = "idle";
      daemonIOSchedClass = "idle";
      settings = {
        download-buffer-size = 134217728;
        warn-dirty = false;
        fallback = true;
        connect-timeout = 5;
        trusted-users = [
          "root"
          "@wheel"
        ];
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
    };

    programs.nh.clean = {
      enable = true;
      dates = "weekly";
      extraArgs = "--keep 5 --optimise";
    };
  };
}
