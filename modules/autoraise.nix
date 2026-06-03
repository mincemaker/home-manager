{ pkgs, config, lib, ... }:

{
  home.packages = [ pkgs.autoraise ];

  launchd.agents.autoraise = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    config = {
      ProgramArguments = [
        # Use stable path on main APFS volume so macOS TCC can validate the
        # permission during early boot (nix store volume isn't mounted yet).
        "${config.home.homeDirectory}/Applications/Home Manager Apps/AutoRaise.app/Contents/MacOS/AutoRaise"
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
