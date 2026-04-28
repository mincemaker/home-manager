{ config, lib, anthropic-skills, agent-browser, ... }:

let
  cfg = config.programs.agent-skills;
in {
  config = lib.mkIf cfg.enable {
    programs.agent-skills = {
      sources.anthropic = {
        path = anthropic-skills;
        subdir = "skills";
      };
      sources.vercel = {
        path = agent-browser;
        subdir = "skills";
      };
      skills.enable = [ "frontend-design" "skill-creator" "agent-browser" ];
      targets.gemini.enable = true;
      targets.codex.enable = false;
      targets.opencode.enable = false;
    };
  };
}
