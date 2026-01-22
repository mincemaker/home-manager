{ config, pkgs, ... }:

{
  # ════════════════════════════════════════════════════════════════════════════
  # シェル切り替え方法
  # ════════════════════════════════════════════════════════════════════════════
  #
  # noctalia-shell 使用時（現在）:
  #   imports に niri.nix + noctalia-shell.nix を含める
  #   programs.noctalia-shell.enable = true;
  #
  # iNiR 使用時:
  #   imports を niri-inir.nix + inir.nix に変更
  #   programs.inir.enable = true;
  #
  # ════════════════════════════════════════════════════════════════════════════

  imports = [
    ./modules/xremap.nix
    ./modules/clock-rs.nix
    ./modules/zen-browser.nix
    # noctalia-shell 使用時:
    # ./modules/niri.nix           # noctalia-shell 用
    # ./modules/noctalia-shell.nix
    # iNiR 使用時:
    ./modules/niri-inir.nix    # iNiR 用
    ./modules/inir.nix
  ];

  home.username = "mince";
  home.homeDirectory = "/home/mince";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  # シェル有効化（切り替え時は対応するものを true に）
  # programs.noctalia-shell.enable = true;
  programs.inir.enable = true;
}
