{ config, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."github.com" = {
      User = "git";
      IdentityFile = config.sops.secrets.ssh_key.path;
    };
  };

  home.file.".ssh/known_hosts" = {
    text = "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl\n";
    force = true;
  };

  sops.secrets."ssh_key" = {
    path = "/home/sean/.sops/ssh_key";
    mode = "0600";
  };
}
