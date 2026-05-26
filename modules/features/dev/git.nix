{ ... }:
{
  flake.modules.homeManager.git =
    { config, ... }:
    {
      programs.git.enable = true;

      home.shellAliases = {
        lg = "lazygit";
      };

      programs.lazygit = {
        enable = true;
        settings.disableStartupPopups = true;
      };

      programs.ssh.settings."github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519";
      };

      home.file."${config.home.homeDirectory}/.ssh/known_hosts" = {
        text = ''
          github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
        '';
        force = true;
      };
    };
}
