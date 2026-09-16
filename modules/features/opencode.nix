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

    # Agent orchestration setup - see MEMORY.md. Prompts live in ./opencode/.
    context = ./opencode/AGENTS.md;
    agents = {
      orchestrator = ./opencode/agents/orchestrator.md;
      reviewer = ./opencode/agents/reviewer.md;
      scout = ./opencode/agents/scout.md;
      explore = ./opencode/agents/explore.md;
    };
    commands = {
      orchestrate = ./opencode/commands/orchestrate.md;
      review = ./opencode/commands/review.md;
    };
    settings = {
      default_agent = "orchestrator";
      small_model = "opencode-go/deepseek-v4-flash";
    };
  };

  # Experimental in the pinned package: lets `task` run subagents in the
  # background with automatic result delivery. Remove if it regresses.
  home.sessionVariables.OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS = "true";

  home.shellAliases = {
    c = "opencode --auto";
    ce = "opencode --auto --continue ~/nixos-config";
  };
}
