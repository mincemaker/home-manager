{ config, lib, slash-criticalthink, ... }:

let
  cfg = config.programs.claude;
in {
  options.programs.claude = {
    enable = lib.mkEnableOption "Claude Code configuration";
  };

  config = lib.mkIf cfg.enable {
    home.file.".claude/commands/criticalthink.md".source =
      "${slash-criticalthink}/criticalthink.md";

    programs.agent-skills = {
      enable = true;
      targets.claude = {
        dest = "\${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills";
        structure = "symlink-tree";
      };
    };
  };
}
