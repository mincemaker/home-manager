{ config, lib, slash-criticalthink, anthropic-skills, ... }:

let
  cfg = config.programs.claude;
in {
  options.programs.claude = {
    enable = lib.mkEnableOption "Claude Code configuration";
  };

  config = lib.mkIf cfg.enable {
    # カスタムコマンド
    home.file.".claude/commands/criticalthink.md".source =
      "${slash-criticalthink}/criticalthink.md";

    # agent-skills-nixによるスキル管理
    programs.agent-skills = {
      enable = true;
      sources.anthropic = {
        path = anthropic-skills;
        subdir = "skills";
      };
      skills.enable = [ "frontend-design" "skill-creator" ];
      targets.claude = {
        dest = "\${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills";
        structure = "symlink-tree";
      };
      targets.codex.enable = false;
      targets.opencode.enable = false;
    };
  };
}
