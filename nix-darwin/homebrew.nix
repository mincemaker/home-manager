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
      "k1LoW/tap/mo"
    ];

    casks = [
      "Jean-Tinland/a-bar/a-bar"
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
