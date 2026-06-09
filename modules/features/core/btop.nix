{ ... }:
{
  flake.modules.homeManager.btop = {
    programs.btop = {
      enable = true;
      settings = {
        update_ms = 100;
        theme_background = false;
        shown_gpus = "all";
        gpu_mirror_graph = true;
      };
    };
  };
}
