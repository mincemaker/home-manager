{ pkgs, lib, config, ... }:

{
  home.packages = [ pkgs.autoraise ];

  launchd.agents.autoraise = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.autoraise}/bin/autoraise"
        "-delay" "1"
        "-disableKey" "control"
        "-warpX" "0.5"
        "-warpY" "0.5"
        "-focusDelay" "0"
        "-verbose" "false"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      ProcessType = "Background";
      LimitLoadToSessionType = "Aqua";
    };
  };
}
