{ ... }:
{
  flake.modules.homeManager.application-launcher =
    { ... }:
    {
      programs.fuzzel = {
        enable = true;
        settings = {
          main = {
            dpi-aware = false;
            namespace = "fuzzel";
            icons-enabled = true;
            sort-result = false;
          };
          colors = {
            background = "000000ff";
            text = "ffffffff";
            prompt = "ccccccff";
            input = "ffffffff";
            match = "84c906ff";
            selection = "84c90644";
            selection-text = "ffffffff";
            selection-match = "84c906ff";
            border = "84c90655";
          };
          border = {
            width = 2;
            radius = 12;
          };
        };
      };
    };
}
