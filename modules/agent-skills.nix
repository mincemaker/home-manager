{ config, lib, pkgs, llm-agents, mizchi-explainer, ... }:

let
  cfg = config.programs.agent-skills;
  # verify-doc.mjs looks for dist/<page path>.html while build-html.mjs writes
  # dist/<basename>.html, so --pages with a page in a subdirectory fails.
  explainer =
    if mizchi-explainer.rev == "752da7c687e767c3efd8ea79f63c5f4f3d76e7b5" then
      pkgs.applyPatches {
        name = "mizchi-explainer-patched";
        src = mizchi-explainer;
        patches = [ ./explainer-verify-doc-subdir-pages.patch ];
      }
    else
      mizchi-explainer;
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
          path = explainer;
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
        ponytail = {
          input = "ponytail";
          subdir = "skills";
        };
        be-ambitious.input = "be-ambitious";
        workmux = {
          input = "workmux";
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
          "be-ambitious"
          "workmux"
        ];
        explicit = {
          skill-creator = {
            from = "anthropic";
            agents = [ "claude" "gemini" ];
          };
        } // lib.genAttrs [
          "ponytail"
          "ponytail-audit"
          "ponytail-debt"
          "ponytail-gain"
          "ponytail-help"
          "ponytail-review"
        ] (_: {
          from = "ponytail";
          agents = [ "gemini" ];
        });
      };
      excludePatterns = [ "/.system" "/hunk-review" "/wiki-*" ];
      targets = {
        agents.enable = true;
        gemini.enable = true;
      };
    };
  };
}
