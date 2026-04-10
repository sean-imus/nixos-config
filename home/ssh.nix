# =============================================================================
# SSH MODULE - SSH configuration
# =============================================================================

{ config, lib, pkgs, ... }:

{
  options = { };

  config = {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "github.com" = {
          user = "git";
          identityFile = "~/.ssh/id_ed25519";
        };
      };
    };
  };
}