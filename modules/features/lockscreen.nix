{
  flake.modules.homeManager.lockscreen =
    { pkgs, ... }:
    {
      programs.swaylock = {
        enable = true;
        settings.color = "000000";
      };

      services.swayidle = {
        enable = true;
        events.lock = "${pkgs.quickshell}/bin/quickshell -c qs-shell ipc call lock lock || ${pkgs.swaylock}/bin/swaylock -f";
      };
    };
}
