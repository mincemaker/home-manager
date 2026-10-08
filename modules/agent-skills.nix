{ config, lib, anthropic-skills, agent-browser, awesome-copilot, ... }:

let
  cfg = config.programs.agent-skills;
in {
  config = lib.mkIf cfg.enable {
    programs.agent-skills = {
      sources = {
        anthropic = {
          path = anthropic-skills;
          subdir = "skills";
        };
        vercel = {
          path = agent-browser;
          subdir = "skills";
        };
        github = {
          path = awesome-copilot;
          subdir = "skills";
          filter.nameRegex = "^git-commit$";
        };
      };
      skills.enable = [
        "frontend-design"
        "agent-browser"
        "git-commit"
      ];
      skills.explicit.skill-creator = {
        from = "anthropic";
        agents = [ "claude" "gemini" "opencode" ];
      };
      excludePatterns = [ "/.system" "/hunk-review" ];
      targets = {
        gemini.enable = true;
        codex.enable = true;
        opencode.enable = true;
      };
    };
  };
}
