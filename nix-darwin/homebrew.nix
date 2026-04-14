{ ... }:

{
  homebrew = {
    enable = true;

    brews = [
      "bat"
      "btop"
      "eza"
      "fd"
      "gh"
      "gemini-cli"
      "gnupg"
      "lazygit"
      "pinentry-mac"
      "ripgrep"
      "rtk"
      "k1LoW/tap/mo"
    ];

    casks = [
      "azookey"
      "bitwarden"
      "claude-code"
      "copilot-cli"
      "ghostty"
      "karabiner-elements"
      "macskk"
      "obsidian"
      "raycast"
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
