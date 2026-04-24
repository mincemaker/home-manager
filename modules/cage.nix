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
            - "/private/tmp"
            - "/var/folders"
            - "/private/var/folders"
            - "/Library/Caches"
            - "$HOME/Library/Caches"
            - "/dev"
            - "/dev/tty"

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

        gemini:
          allow:
            - "$HOME/.gemini"
            - "$HOME/.serena"
            - ".serena"

        git-enabled:
          allow-git: true
          allow-keychain: true

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

        - command: gemini
          presets:
            - base
            - git-enabled
            - gemini
    '';

    home.packages = [ cage.packages.${system}.default ];
    home.file = lib.mkIf pkgs.stdenv.isDarwin {
      "Library/Application Support/cage/presets.yaml".text = cfg.settings;
    };
    xdg.configFile = lib.mkIf (!pkgs.stdenv.isDarwin) {
      "cage/presets.yaml".text = cfg.settings;
    };
  };
}
