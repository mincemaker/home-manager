{ config, lib, pkgs, slash-criticalthink, ... }:

let
  cfg = config.programs.claude;
  mo = pkgs.stdenv.mkDerivation {
    pname = "mo";
    version = "1.3.0";
    src = pkgs.fetchurl {
      url = "https://github.com/k1LoW/mo/releases/download/v1.3.0/mo_v1.3.0_linux_amd64.tar.gz";
      hash = "sha256-BJn7yOmd2Ilb63BJo4La/KCGTxM28xFotKGwL09RYxM=";
    };
    sourceRoot = ".";
    installPhase = ''
      mkdir -p $out/bin
      cp mo $out/bin/mo
    '';
  };
in {
  options.programs.claude = {
    enable = lib.mkEnableOption "Claude Code configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ mo ];

    home.file.".claude/commands/criticalthink.md".source =
      "${slash-criticalthink}/criticalthink.md";

    home.file.".claude/hooks/open-plan-mo.sh" = {
      executable = true;
      text = ''
        #!/bin/bash
        INPUT=$(cat)
        PLAN_FILE=$(echo "$INPUT" | jq -r '.tool_response.filePath // empty' 2>/dev/null)

        if [ -n "$PLAN_FILE" ] && [ -f "$PLAN_FILE" ]; then
            mo "$PLAN_FILE" &
            disown
        fi
      '';
    };

    home.file.".claude/settings.json".source =
      let
        settings = {
          permissions = {
            allow = [
              "Bash(qs:*)"
              "WebSearch"
              "WebFetch(domain:docs.noctalia.dev)"
              "WebFetch(domain:github.com)"
              "WebFetch(domain:quickshell.outfoxxed.me)"
              "WebFetch(domain:quickshell.org)"
              "Bash(systemctl --user show-environment:*)"
              "WebFetch(domain:medium.com)"
            ];
            defaultMode = "plan";
          };
          hooks = {
            PreToolUse = [
              {
                matcher = "";
                hooks = [{ type = "command"; command = "guard-and-guide"; }];
              }
              {
                matcher = "Bash";
                hooks = [{ type = "command"; command = "/home/mince/.claude/hooks/rtk-rewrite.sh"; }];
              }
            ];
            PostToolUse = [
              {
                matcher = "ExitPlanMode";
                hooks = [{ type = "command"; command = "/home/mince/.claude/hooks/open-plan-mo.sh"; }];
              }
            ];
          };
          statusLine = { type = "command"; command = "bunx ccusage statusline"; padding = 0; };
          language = "Japanese";
          enabledPlugins = { "ruby-lsp@claude-plugins-official" = true; };
        };
      in
      pkgs.runCommand "claude-settings.json" {} ''
        ${pkgs.jq}/bin/jq '.' \
          ${pkgs.writeText "claude-settings-raw.json" (builtins.toJSON settings)} \
          > $out
      '';

    programs.agent-skills = {
      enable = true;
      targets.claude = {
        dest = "\${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills";
        structure = "symlink-tree";
      };
    };
  };
}
