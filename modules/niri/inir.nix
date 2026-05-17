{ pkgs, lib, config, inir, ... }:
let
  cfg = config.programs.inir;
in {
  options.programs.inir.enable = lib.mkEnableOption "iNiR shell";

  config = lib.mkIf cfg.enable {
    # iNiR を ~/.config/quickshell/ii に配置
    home.file.".config/quickshell/inir" = {
      source = inir;
      recursive = true;
    };

    # 依存パッケージ（nixpkgs から）
    home.packages = with pkgs; [
      # Core
      cliphist
      wl-clipboard
      libnotify
      gum
      awww
      # Screenshot & Recording
      grim
      slurp
      swappy
      wf-recorder
      imagemagick
      ffmpeg
      tesseract
      # Input & Idle
      swayidle
      wtype
      brightnessctl
      # Audio
      playerctl
      # Qt6 追加
      kdePackages.kdialog
      # Theming
      fuzzel
    ];

    # dots/.config/ から追加設定ファイルを配置
    home.file.".config/matugen".source = "${inir}/dots/.config/matugen";
    home.file.".config/fuzzel/fuzzel.ini".source = "${inir}/dots/.config/fuzzel/fuzzel.ini";

    # systemd user service
    systemd.user.services.inir = {
      Unit = {
        Description = "iNiR Shell";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        Conflicts = [ "noctalia-shell.service" ];
        # inir ソースが変わったら home-manager switch 後に自動再起動
        X-Restart-Triggers = [ (toString inir) ];
      };
      Service = {
        ExecStart = "${inir}/scripts/inir run --session";
        Restart = "on-failure";
        Environment = [
          "QT_QPA_PLATFORM=wayland"
          "QT_WAYLAND_CLIENT_BUFFER_INTEGRATION=wayland-egl"
          "EGL_PLATFORM=wayland"
          "PATH=${lib.makeBinPath (with pkgs; [ imagemagick ffmpeg tesseract grim slurp awww ])}:%h/.nix-profile/bin:/usr/bin:/bin"
        ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
      # inir ソースが変わったら home-manager switch 後に自動再起動
    };
  };
}
