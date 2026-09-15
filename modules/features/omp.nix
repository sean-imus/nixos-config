{ lib, pkgs, ... }:
let
  ompConfig = (pkgs.formats.yaml { }).generate "omp-config.yml" {
    symbolPreset = "nerd";
    theme.dark = "dark-forest";
    startup.quiet = true;
    startup.checkUpdate = false;
  };
in
{
  home.packages = [ pkgs.omp ];

  # OMP locks and rewrites its config at runtime, so it must be a writable
  # regular file rather than a read-only store symlink. Declared values win
  # on every activation.
  home.activation.ompConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "$HOME/.omp/agent"
    run install -m 600 ${ompConfig} "$HOME/.omp/agent/config.yml"
  '';
}
