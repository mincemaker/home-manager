{ pkgs, lib, config, inir, ... }:
let
  cfg = config.programs.inir;
in {
  options.programs.inir.enable = lib.mkEnableOption "iNiR shell";

  config = lib.mkIf cfg.enable {
    # iNiR を ~/.config/quickshell/ii に配置
    home.file.".config/quickshell/ii" = {
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
    # illogical-impulse は書き込み可能にするため activation で初期化
    home.file.".config/matugen".source = "${inir}/dots/.config/matugen";
    home.file.".config/fuzzel/fuzzel.ini".source = "${inir}/dots/.config/fuzzel/fuzzel.ini";

    # illogical-impulse を書き込み可能なディレクトリとして初期化
    home.activation.initIllogicalImpulse = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      configDir="$HOME/.config/illogical-impulse"
      sourceDir="${inir}/dots/.config/illogical-impulse"

      # シンボリックリンクの場合は削除してコピー
      if [ -L "$configDir" ]; then
        rm "$configDir"
      fi

      # ディレクトリが存在しなければコピー
      if [ ! -d "$configDir" ]; then
        mkdir -p "$configDir"
        cp -r "$sourceDir"/* "$configDir/"
        chmod -R u+w "$configDir"
      fi
    '';

    # systemd user service
    systemd.user.services.inir = {
      Unit = {
        Description = "iNiR Shell";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        Conflicts = [ "noctalia-shell.service" ];
      };
      Service = {
        ExecStart = "/usr/bin/qs -c ii";
        Restart = "on-failure";
        Environment = [
          "QT_QPA_PLATFORM=wayland"
          "QT_WAYLAND_CLIENT_BUFFER_INTEGRATION=wayland-egl"
          "EGL_PLATFORM=wayland"
          "PATH=${lib.makeBinPath (with pkgs; [ imagemagick ffmpeg tesseract grim slurp ])}:%h/.nix-profile/bin:/usr/bin:/bin"
        ];
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
