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
      "bitwarden"
      "copilot-cli"
      "ghostty"
      "jordanbaird-ice"
      "karabiner-elements"
      "macskk"
      "obsidian"
      "postgres-app"
      "raycast"
      "secretive"
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
