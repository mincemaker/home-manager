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
      ExecStart = "${pkgs.quickshell}/bin/qs -c ${noctalia-shell.packages.${pkgs.system}.default}";
      Restart = "on-failure";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
