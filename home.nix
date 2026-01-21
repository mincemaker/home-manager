{ config, pkgs, ... }:

{
  imports = [
    ./modules/xremap.nix
    ./modules/clock-rs.nix
    ./modules/zen-browser.nix
    ./modules/niri.nix
    ./modules/noctalia-shell.nix
  ];

  home.username = "mince";
  home.homeDirectory = "/home/mince";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
