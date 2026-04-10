# =============================================================================
# GIT MODULE - Git configuration
# =============================================================================

{ config, lib, pkgs, ... }:

{
  options = { };

  config = {
    programs.git = {
      enable = true;
      settings = {
        user = {
          Name = "Sean Tietz";
          Email = "sean.tietz2@gmail.com";
        };
      };
    };
  };
}