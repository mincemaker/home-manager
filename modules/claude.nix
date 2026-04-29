{ config, lib, pkgs, slash-criticalthink, ... }:

let
  cfg = config.programs.claude;
  inherit (config.lib.file) mkOutOfStoreSymlink;
  claudeDir = "${config.home.homeDirectory}/.config/home-manager/modules/claude";
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
      (pkgs.writeShellApplication {
        name = "deepwiki-guard";
        runtimeInputs = [ pkgs.jq pkgs.gh ];
        text = ''
          INPUT=$(cat)
          REPO_NAME=$(echo "$INPUT" | jq -r '.tool_input.repoName // empty')

          if [ -z "$REPO_NAME" ]; then
            exit 0
          fi

          if ! echo "$REPO_NAME" | grep -q '/'; then
            exit 0
          fi

          VISIBILITY=$(gh repo view "$REPO_NAME" --json visibility -q '.visibility' 2>/dev/null || true)

          if [ -z "$VISIBILITY" ] || [ "$VISIBILITY" = "PUBLIC" ]; then
            exit 0
          fi

          REASON="DeepWiki MCPへのアクセスをブロックしました: '$REPO_NAME' はプライベートリポジトリです (visibility: $VISIBILITY)。"
          jq -n --arg reason "$REASON" \
            '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "deny", permissionDecisionReason: $reason}}'
          exit 0
        '';
      })
    ];

    home.file.".claude/commands/criticalthink.md".source =
      "${slash-criticalthink}/criticalthink.md";

    home.file.".claude/settings.json".source =
      mkOutOfStoreSymlink "${claudeDir}/settings.json";

    home.file.".claude/CLAUDE.md".source =
      mkOutOfStoreSymlink "${claudeDir}/CLAUDE.md";

    home.file.".claude/agents/gemini-explore.md".source =
      mkOutOfStoreSymlink "${claudeDir}/agents/gemini-explore.md";

    programs.agent-skills = {
      enable = true;
      targets.claude = {
        dest = "\${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills";
        structure = "symlink-tree";
      };
    };
  };
}
