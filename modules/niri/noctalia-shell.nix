{ pkgs, lib, config, noctalia-shell, ... }:
let
  cfg = config.programs.noctalia-shell;
in {
  options.programs.noctalia-shell.enable = lib.mkEnableOption "noctalia-shell";

  config = lib.mkIf cfg.enable {
    home.packages = [
      noctalia-shell.packages.${pkgs.system}.default
    ];

    systemd.user.services.noctalia-shell = {
      Unit = {
        Description = "Noctalia Shell";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        Conflicts = [ "inir.service" ];
      };
      Service = {
        ExecStart = "/usr/bin/qs -p ${noctalia-shell.packages.${pkgs.system}.default}/share/noctalia-shell";
        Restart = "on-failure";
        Environment = [
          "QT_QPA_PLATFORM=wayland"
          "QT_WAYLAND_CLIENT_BUFFER_INTEGRATION=wayland-egl"
          "EGL_PLATFORM=wayland"
        ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
