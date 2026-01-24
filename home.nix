{ config, pkgs, ... }:

{
  imports = [
    ./modules/xremap.nix
    ./modules/clock-rs.nix
    ./modules/zen-browser.nix
    ./modules/niri              # 統合niriモジュール
    ./modules/noctalia-shell.nix
    ./modules/inir.nix
    ./modules/stasis.nix        # アイドル管理
  ];

  home.username = "mince";
  home.homeDirectory = "/home/mince";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # niri設定（shellを変えるだけで切り替え可能）
  programs.niri = {
    enable = true;
    shell = "inir";  # "noctalia" または "inir"
  };
}
