{ config, ... }:
{
  programs.git = {
    enable = true;
    settings.user = {
      name = "sean tietz";
      email = "sean.tietz2@gmail.com";
    };
  };

  programs.lazygit = {
    enable = true;
    settings.gui.theme = {
      activeBorderColor = [
        "#a7c080"
        "bold"
      ];
      inactiveBorderColor = [ "#7a8478" ];
      optionsTextColor = [ "#9da9a0" ];
      selectedLineBgColor = [ "#343f44" ];
      unstagedChangesColor = [ "#e67e80" ];
      defaultFgColor = [ "#d3c6aa" ];
      searchingActiveBorderColor = [
        "#dbbc7f"
        "bold"
      ];
    };
  };
  home.shellAliases = {
    lg = "lazygit";
  };

  programs.ssh = {
    settings."github.com" = {
      User = "git";
      IdentityFile = config.sops.secrets.ssh_key.path;
    };

    settings."medion-server1" = {
      HostName = "192.168.178.201";
      User = "sean";
      IdentityFile = config.sops.secrets.ssh_key.path;
      IdentitiesOnly = true;
    };

    settings."medion-server2" = {
      HostName = "192.168.178.202";
      User = "sean";
      IdentityFile = config.sops.secrets.ssh_key.path;
      IdentitiesOnly = true;
    };
  };

  home.file.".ssh/known_hosts" = {
    text = "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl\n";
    force = true;
  };
}
