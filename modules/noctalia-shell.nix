{ pkgs, noctalia-shell, ... }:

# Noctalia Shell Configuration
# Configures the noctalia-shell package and sets it up as a Systemd user service.
# This ensures the shell runs automatically and restarts on failure.

{
  home.packages = [
    noctalia-shell.packages.${pkgs.system}.default
  ];

  systemd.user.services.noctalia-shell = {
    Unit = {
      Description = "Noctalia Shell";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
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
}
