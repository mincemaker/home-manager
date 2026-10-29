{ config, ... }:

let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  piCfgDir = "${config.home.homeDirectory}/.config/home-manager/modules/pi";
in {
  home.file = {
    ".pi/agent/keybindings.json".source =
      mkOutOfStoreSymlink "${piCfgDir}/keybindings.json";
    ".pi/agent/AGENTS.md".source =
      mkOutOfStoreSymlink "${piCfgDir}/instructions.md";
    ".pi/agent/extensions".source =
      mkOutOfStoreSymlink "${piCfgDir}/extensions";
  };
}
