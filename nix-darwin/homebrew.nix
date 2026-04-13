{ ... }:

{
  homebrew = {
    enable = true;

    brews = [
      "bat"
      "eza"
      "fd"
      "gh"
      "gemini-cli"
      "gnupg"
      "pinentry-mac"
      "ripgrep"
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
      "tailscale-app"
      "visual-studio-code"
      "zen"
    ];

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
    };
  };
}
