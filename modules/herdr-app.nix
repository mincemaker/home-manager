{ config, lib, pkgs, ... }:

let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
  herdrCfgDir = "${config.home.homeDirectory}/.config/home-manager/modules/herdr-app";
  keys = if isDarwin then "keys-darwin.json" else "keys-linux.json";
in {
  xdg.configFile = {
    "herdr-app/keys.json".source = mkOutOfStoreSymlink "${herdrCfgDir}/${keys}";
  } // lib.optionalAttrs isDarwin {
    "herdr-app/mods/tmux-prefix".source =
      mkOutOfStoreSymlink "${herdrCfgDir}/mods/tmux-prefix";
  };
}
