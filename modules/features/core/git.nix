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
      optionsTextColor = [ "#7fbbb3" ];
      selectedLineBgColor = [ "#3a454a" ];
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
  };

  home.file.".ssh/known_hosts" = {
    text = "github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl\n";
    force = true;
  };
}
