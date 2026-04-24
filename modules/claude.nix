{ config, lib, pkgs, slash-criticalthink, ... }:

let
  cfg = config.programs.claude;
in {
  options.programs.claude = {
    enable = lib.mkEnableOption "Claude Code configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.jq
      (pkgs.writeShellApplication {
        name = "open-plan-mo";
        runtimeInputs = [ pkgs.jq ];
        text = ''
          INPUT=$(cat)
          PLAN_FILE=$(echo "$INPUT" | jq -r '.tool_response.filePath // empty' 2>/dev/null)

          if [ -n "$PLAN_FILE" ] && [ -f "$PLAN_FILE" ]; then
              if command -v mo >/dev/null 2>&1; then
                  mo "$PLAN_FILE" &
                  disown
              else
                  echo "Error: 'mo' not found. Please install it via 'mise use -g github:k1LoW/mo@latest'" >&2
              fi
          fi
        '';
      })
    ];

    home.file.".claude/commands/criticalthink.md".source =
      "${slash-criticalthink}/criticalthink.md";

    home.file.".claude/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.config/home-manager/modules/claude/settings.json";

    programs.agent-skills = {
      enable = true;
      targets.claude = {
        dest = "\${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills";
        structure = "symlink-tree";
      };
    };
  };
}
