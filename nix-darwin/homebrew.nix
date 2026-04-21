{ ... }:

{
  homebrew = {
    enable = true;

    brews = [
      "bat"
      "btop"
      "eza"
      "git-delta"
      "fd"
      "gh"
      "gnupg"
      "lazygit"
      "pinentry-mac"
      "ripgrep"
      "rtk"
      "k1LoW/tap/mo"
    ];

    casks = [
      "azookey"
      "battery-buddy"
      "bitwarden"
      "chatgpt-atlas"
      "copilot-cli"
      "discord"
      "ghostty"
      "karabiner-elements"
      "macskk"
      "obsidian"
      "postgres-app"
      "raycast"
      "secretive"
      "spotify"
      "tailscale-app"
      "thaw"
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
