{ config, lib, pkgs, llm-agents, ... }:

let
  cfg = config.programs.agent-skills;
in {
  config = lib.mkIf cfg.enable {
    programs.agent-skills = {
      sources = {
        anthropic = {
          input = "anthropic-skills";
          subdir = "skills";
        };
        vercel = {
          input = "agent-browser";
          subdir = "skills";
        };
        github = {
          input = "awesome-copilot";
          subdir = "skills";
          filter.nameRegex = "^git-commit$";
        };
        mizchi = {
          input = "mizchi-skills";
          filter.nameRegex = "^(apm-usage|empirical-prompt-tuning)$";
        };
        mizchi-explainer = {
          input = "mizchi-explainer";
          subdir = "skills";
        };
        mattpocock = {
          input = "mattpocock-skills";
          subdir = "skills/productivity";
          filter.nameRegex = "^(grill-me|grilling)$";
        };
        jj = {
          input = "jj-skills";
          subdir = "skills";
          filter.nameRegex = "^jj-workflow$";
        };
        herdr-core = {
          path = "${llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr-core}/share/skills/herdr-core";
        };
        declscope = {
          input = "declscope";
          subdir = "skills";
          filter.nameRegex = "^declscope-adoption$";
        };
        eli5 = {
          input = "claude-plugins-community";
          subdir = "eli5/skills";
        };
        archify = {
          input = "archify";
          filter.nameRegex = "^archify$";
        };
        yomiyasu = {
          input = "yomiyasu";
          subdir = "skills";
        };
      };
      skills = {
        enable = [
          "frontend-design"
          "agent-browser"
          "git-commit"
        ];
        enableAll = [
          "mizchi"
          "mizchi-explainer"
          "mattpocock"
          "jj"
          "herdr-core"
          "declscope"
          "eli5"
          "archify"
          "yomiyasu"
        ];
        explicit.skill-creator = {
          from = "anthropic";
          agents = [ "claude" "gemini" ];
        };
      };
      excludePatterns = [ "/.system" "/hunk-review" "/wiki-*" ];
      targets = {
        agents.enable = true;
        gemini.enable = true;
      };
    };
  };
}
