{ ... }:

{
  homebrew = {
    enable = true;

    brews = [
      "gh"
      "gnupg"
      "pinentry-mac"
      "rtk"
    ];

    casks = [
      "azookey"
      "bitwarden"
      "claude-code"
      "copilot-cli"
      "ghostty"
      "macskk"
      "obsidian"
      "visual-studio-code"
    ];

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
  };
}
