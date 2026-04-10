# =============================================================================
# NEOVIM MODULE - Neovim editor configuration
# =============================================================================

{
  config,
  lib,
  pkgs,
  ...
}:

{
  options = { };

  config = {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };
  };
}
