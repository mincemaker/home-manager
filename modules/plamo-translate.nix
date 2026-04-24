{ config, lib, pkgs, ... }:

let
  cfg = config.programs.plamo-translate;
in {
  options.programs.plamo-translate = {
    enable = lib.mkEnableOption "PLaMo translation CLI";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "plamo-translate";
        runtimeInputs = [ pkgs.uv ];
        text = ''
          # Install to a private directory not in PATH so this wrapper is the sole entry point
          export UV_TOOL_BIN_DIR="$HOME/.local/share/uv/bin"
          UV_TOOL_BIN="$UV_TOOL_BIN_DIR/plamo-translate"

          if [[ ! -x "$UV_TOOL_BIN" ]]; then
            echo "plamo-translate not found. Installing via uv..." >&2
            uv tool install --force --with torch plamo-translate >&2
            echo "Installation complete." >&2
          fi

          export TMPDIR="''${TMPDIR:-/tmp}"
          # Suppress harmless warnings: transformers probes optional CUDA libs on import
          export PYTHONWARNINGS="ignore:mamba_ssm could not be imported:UserWarning,ignore:causal_conv1d could not be imported:UserWarning"

          exec "$UV_TOOL_BIN" "$@"
        '';
      })
    ];
  };
}
