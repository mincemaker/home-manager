{ config, lib, ... }:

let
  cfg = config.programs.hunk;
in {
  config = lib.mkIf cfg.enable {
    programs.hunk = {
      enableGitIntegration = true;
      enableJujutsuIntegration = true;
      enableClaudeIntegration = true;
    };
  };
}
