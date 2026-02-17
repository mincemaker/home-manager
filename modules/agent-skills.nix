{ config, lib, anthropic-skills, ... }:

let
  cfg = config.programs.agent-skills;
in {
  config = lib.mkIf cfg.enable {
    programs.agent-skills = {
      sources.anthropic = {
        path = anthropic-skills;
        subdir = "skills";
      };
      skills.enable = [ "frontend-design" "skill-creator" ];
      targets.gemini.enable = true;
      targets.codex.enable = false;
      targets.opencode.enable = false;
    };
  };
}
