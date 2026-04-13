{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
    ../modules/niri/xremap.nix
    ../modules/niri/clock-rs.nix
    ../modules/niri/zen-browser.nix
    ../modules/niri
    ../modules/niri/noctalia-shell.nix
    ../modules/niri/inir.nix
  ];

  home.username = "mince";
  home.homeDirectory = "/home/mince";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  programs.fish.enable = true;

  programs.zsh.shellAliases = {
    ls = "ls --color=auto";
  };

  programs.niri = {
    enable = true;
    shell = "inir";
  };

  programs.claude.enable = true;
}
