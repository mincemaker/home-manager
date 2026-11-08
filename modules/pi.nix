{ config, ... }:

let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  piCfgDir = "${config.home.homeDirectory}/.config/home-manager/modules/pi";
in {
  programs.pi-coding-agent = {
    enable = true;
    package = null;
    mutableSettings = true;
    settings.packages = [
      "npm:pi-subagents"
      "npm:pi-web-access"
      "npm:pi-prompt-template-model"
      "git:github.com/nicobailon/visual-explainer"
    ];
  };

  home.file = {
    ".pi/agent/prompts/commit.md".source =
      mkOutOfStoreSymlink "${piCfgDir}/prompts/commit.md";
    ".pi/agent/keybindings.json".source =
      mkOutOfStoreSymlink "${piCfgDir}/keybindings.json";
    ".pi/agent/AGENTS.md".source =
      mkOutOfStoreSymlink "${piCfgDir}/instructions.md";
    ".pi/agent/extensions".source =
      mkOutOfStoreSymlink "${piCfgDir}/extensions";
  };
}
