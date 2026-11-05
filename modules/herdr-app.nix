{ config, pkgs, ... }:

let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  herdrCfgDir = "${config.home.homeDirectory}/.config/home-manager/modules/herdr-app";
  keys = if pkgs.stdenv.hostPlatform.isDarwin then "keys-darwin.json" else "keys-linux.json";
in {
  xdg.configFile = {
    "herdr-app/keys.json".source = mkOutOfStoreSymlink "${herdrCfgDir}/${keys}";
    "herdr-app/mods/tmux-prefix".source =
      mkOutOfStoreSymlink "${herdrCfgDir}/mods/tmux-prefix";
  };
}
