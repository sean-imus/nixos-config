# =============================================================================
# CHROMIUM MODULE - Browser configuration
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
    programs.chromium = {
      enable = true;
      # uBlock Origin Lite extension ID
      extensions = [ "ddkjiahejlhfcafbddmgiahcphecmpfh" ];
    };
  };
}
