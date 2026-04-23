{ config, lib, pkgs, ... }:

let
  cfg = config.programs.plamo-translate;
in {
  options.programs.plamo-translate = {
    enable = lib.mkEnableOption "PLaMo translation CLI (with torch and warning suppression)";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "plamo-translate" ''
        set -o errexit
        set -o nounset
        set -o pipefail

        # Use uv from the system
        export PATH="${pkgs.uv}/bin:$PATH"

        # Standard installation location (as user expects)
        UV_TOOL_BIN="$HOME/.local/bin/plamo-translate"

        # Install via uv into standard bin, with torch to avoid ImportError
        if [[ ! -x "$UV_TOOL_BIN" ]]; then
          echo "plamo-translate not found or incorrect dependencies. Installing via uv..." >&2
          uv tool install --force --with torch plamo-translate >&2
          echo "Installation complete." >&2
        fi

        # Just execute if not already in PATH or being shadowed
        exec "$UV_TOOL_BIN" "$@"
      '')
    ];

    # Suppress harmless warnings from transformers (e.g., mamba_ssm/causal_conv1d missing on macOS)
    # This alias takes precedence over the binary in PATH.
    programs.zsh.shellAliases = {
      plamo-translate = "env PYTHONWARNINGS='ignore:mamba_ssm could not be imported:UserWarning,ignore:causal_conv1d could not be imported:UserWarning' plamo-translate";
    };
  };
}
