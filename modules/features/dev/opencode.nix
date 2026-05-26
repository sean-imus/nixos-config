{ ... }:
{
  flake.modules.homeManager.opencode =
    { pkgs, config, lib, ... }:
    {
      home.shellAliases = {
        c = "opencode";
      };

      programs.opencode = {
        enable = true;
        settings = {
          autoupdate = false;
          formatter = true;
          lsp = true;
          mcp = {
            nixos = {
              command = [ "${pkgs.mcp-nixos}/bin/mcp-nixos" ];
              enabled = true;
              type = "local";
            };
          };
        };
        tui = {
          theme = "system";
        };
      };

      home.packages = with pkgs; [
        nixd
      ];

      home.activation.mergeOpencodeAuth = lib.hm.dag.entryAfter ["writeBoundary"] ''
        AUTH_KEY_PATH="${config.home.homeDirectory}/.config/opencode/auth_key"
        CONFIG_PATH="${config.home.homeDirectory}/.config/opencode/opencode.json"
        if [ -f "$AUTH_KEY_PATH" ] && [ -f "$CONFIG_PATH" ]; then
          API_KEY="$(cat "$AUTH_KEY_PATH")"
          ${pkgs.jq}/bin/jq --arg key "$API_KEY" '.auth.apiKey = $key' \
            "$CONFIG_PATH" > "$CONFIG_PATH.tmp" \
            && mv "$CONFIG_PATH.tmp" "$CONFIG_PATH"
        fi
      '';
    };
}
