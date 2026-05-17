{ pkgs, lib, config, inir, ... }:
let
  cfg = config.programs.inir;
in {
  options.programs.inir.enable = lib.mkEnableOption "iNiR shell";

  config = lib.mkIf cfg.enable {
    # quickshell の設定ファイルを配置（inir run --session がここを参照する）
    home.file.".config/quickshell/inir" = {
      source = inir;
      recursive = true;
    };

    # 依存パッケージ（nixpkgs から）
    home.packages = with pkgs; [
      # inir CLI を PATH に公開（symlink で script_dir が正しく解決される）
      (pkgs.runCommand "inir-cli" {} ''
        mkdir -p $out/bin
        ln -s ${inir}/scripts/inir $out/bin/inir
      '')
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

    # iNiR 公式のサービス管理機能でサービスファイルを生成・有効化する。
    # inir service install: assets/systemd/inir.service テンプレートから
    #   ExecStart を現在のランチャーパスに書き換えて
    #   ~/.config/systemd/user/inir.service を生成する。
    # inir service enable: niri.service.wants/ に自動起動リンクを作る。
    home.activation.inirServiceSetup = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      export PATH="/usr/bin:/usr/local/bin:$PATH"
      ${inir}/scripts/inir service install
      ${inir}/scripts/inir service enable || true
    '';
  };
}
