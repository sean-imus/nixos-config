{ inputs, ... }:
{
  # Desktop is a machine capability, not a per-user choice: a host imports the
  # `desktop` bucket once and every user on it gets the graphical stack. This
  # single line bridges the two halves — the nixos.desktop bucket (compositor,
  # portals, CUPS, PAM, …) carries the HM bucket into every user via
  # sharedModules, so desktop can never be half-wired (system on, HM off or
  # vice-versa). Feature files never touch this; they just write into the buckets.
  flake.modules.nixos.desktop.home-manager.sharedModules = [
    inputs.self.modules.homeManager.desktop
  ];
}
