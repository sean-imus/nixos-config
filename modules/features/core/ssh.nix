{ lib, ... }:
{
  flake.modules.nixos.ssh =
    { config, ... }:
    {
      options.hostCfg.ssh-server.enable = lib.mkEnableOption "OpenSSH Server";

      config = lib.mkIf config.hostCfg.ssh-server.enable {
        services.openssh = {
          enable = true;
          settings = {
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false;
            PermitRootLogin = "prohibit-password";
          };
        };
      };
    };

  flake.modules.homeManager.ssh =
    { ... }:
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
      };
    };
}
