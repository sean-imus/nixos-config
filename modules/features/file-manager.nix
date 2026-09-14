{ inputs, pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true;

    flavors.everforest-medium-dark = "${inputs.yazi-everforest}/everforest-medium-dark.yazi";

    theme.flavor.dark = "everforest-medium-dark";

    settings = {
      mgr = {
        ratio = [
          1
          4
          3
        ];
        sort_by = "natural";
        sort_sensitive = false;
        sort_dir_first = true;
        linemode = "size";
        show_hidden = false;
        show_symlink = true;
        scrolloff = 5;
      };

      preview = {
        wrap = "yes";
        tab_size = 2;
      };
    };

    keymap = {
      mgr.append_keymap = [
        {
          on = [
            "g"
            "r"
          ];
          run = "cd --interactive";
          desc = "Jump to a path";
        }
        {
          on = [
            "g"
            "d"
          ];
          run = "cd ~/Downloads";
          desc = "Go to Downloads";
        }
        {
          on = [
            "g"
            "n"
          ];
          run = "cd ~/nixos-config";
          desc = "Go to nixos-config";
        }
        {
          on = [
            "g"
            "."
          ];
          run = "cd ~/.config";
          desc = "Go to ~/.config";
        }
      ];
    };

    extraPackages = with pkgs; [
      file
      fd
      ripgrep
      jq
    ];
  };
}
