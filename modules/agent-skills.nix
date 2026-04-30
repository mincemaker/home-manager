{ config, lib, anthropic-skills, agent-browser, awesome-copilot, ... }:

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
      sources.github = {
        path = awesome-copilot;
        subdir = "skills";
        filter.nameRegex = "^git-commit$";
      };
      skills.enable = [
        "frontend-design"
        "skill-creator"
        "agent-browser"
        "git-commit"
      ];
      targets.gemini.enable = true;
      targets.codex.enable = false;
      targets.opencode.enable = false;
    };
  };
}
