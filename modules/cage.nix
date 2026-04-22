{ config, lib, pkgs, cage, ... }:

let
  cfg = config.programs.cage;
  system = pkgs.stdenv.hostPlatform.system;
in {
  options.programs.cage = {
    enable = lib.mkEnableOption "cage filesystem sandbox tool";
    settings = lib.mkOption {
      type = lib.types.lines;
      default = ''
        presets:
          base:
            allow:
              - "."
              - "$XDG_CACHE_HOME"
              - "$XDG_DATA_HOME"
              - "/tmp"
              - "/dev"

          claude-code:
            allow:
              - "$CLAUDE_CONFIG_DIR"

          git-enabled:
            allow-git: true

        auto-presets:
          - command: claude
            presets:
              - base
              - git-enabled
              - claude-code

          - command: git
            presets:
              - base
              - git-enabled
      '';
      description = "Content of ~/.config/cage/presets.yaml";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cage.packages.${system}.default ];
    xdg.configFile."cage/presets.yaml".text = cfg.settings;
  };
}
