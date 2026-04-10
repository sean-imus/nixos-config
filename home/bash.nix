# =============================================================================
# BASH MODULE - Shell configuration
# =============================================================================

{ config, lib, pkgs, ... }:

{
  options = { };

  config = {
    programs.bash = {
      enable = true;
      shellAliases = {
        lg = "lazygit";
        lj = "lazyjournal";
      };
    };

    home.stateVersion = "25.11";
  };
}