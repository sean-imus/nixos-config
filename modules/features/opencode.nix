{ pkgs, inputs, ... }:
{
  programs.mcp = {
    enable = true;
    servers.nixos.command = "${pkgs.mcp-nixos}/bin/mcp-nixos";
  };

  programs.opencode = {
    enable = true;
    # TODO: pinned flake input (see MEMORY.md) — use the nixpkgs package once
    # upstream ships the fix, then drop the input from flake.nix.
    package = inputs.opencode.packages.${pkgs.stdenv.hostPlatform.system}.default;
    enableMcpIntegration = true;
    tui = {
      theme = "system";
    };
  };

  home.shellAliases = {
    c = "opencode --auto";
    ce = "opencode --auto --continue ~/nixos-config";
  };
}
