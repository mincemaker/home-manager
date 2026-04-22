{ config, lib, pkgs, cage, ... }:

let
  cfg = config.programs.cage;
  system = pkgs.stdenv.hostPlatform.system;
in {
  options.programs.cage = {
    enable = lib.mkEnableOption "cage filesystem sandbox tool";
    settings = lib.mkOption {
      type = lib.types.lines;
      description = "Content of ~/.config/cage/presets.yaml";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.cage.settings = lib.mkDefault ''
      presets:
        base:
          allow:
            - "."
            - "${config.xdg.cacheHome}"
            - "${config.xdg.dataHome}"
            - "/tmp"
            - "/dev"

        claude-code:
          allow:
            - "$CLAUDE_CONFIG_DIR"
            - "$HOME/.claude"
            - "$HOME/.claude.json"
            - "$HOME/.claude.json.backup"
            - "$HOME/.claude.json.lock"
            - "$HOME/.claude.lock"
            - "$HOME/.serena"
            - "$HOME/.agent-browser"
            - "$HOME/.browser-profile"
            - "$HOME/.codex"
            - ".serena"

        codex:
          allow:
            - "$HOME/.serena"
            - "$HOME/.agent-browser"
            - "$HOME/.browser-profile"
            - "$HOME/.codex"
            - ".serena"

        npm:
          allow:
            - "$HOME/.npm"
            - "$HOME/.cache/npm"
            - "$HOME/.npmrc"
            - "$HOME/.config/.wrangler"

        git-enabled:
          allow-git: true

      auto-presets:
        - command: claude
          presets:
            - base
            - git-enabled
            - npm
            - claude-code

        - command: git
          presets:
            - base
            - git-enabled
    '';

    home.packages = [ cage.packages.${system}.default ];
    xdg.configFile."cage/presets.yaml".text = cfg.settings;
  };
}
