_:

{
  homebrew = {
    enable = true;

    taps = [
      { name = "dimentium/autoraise"; trusted = true; }
      { name = "FelixKratz/formulae"; trusted = true; }
      { name = "nikitabobko/tap"; trusted = true; }
      { name = "docker/tap"; trusted = true; }
    ];

    brews = [
      "bat"
      "btop"
      "eza"
      "git-delta"
      "fd"
      "gh"
      "gmp"
      "gnupg"
      "lazygit"
      "mise"
      "libyaml"
      "neovim"
      "openssl@3"
      "pinentry-mac"
      "readline"
      "ripgrep"
      "sketchybar"
      "borders"
    ];

    casks = [
      "azookey"
      "bitwarden"
      "chatgpt-atlas"
      "copilot-cli"
      "discord"
      "ghostty"
      "karabiner-elements"
      "macskk"
      "music-decoy"
      "obsidian"
      "postgres-app"
      "raycast"
      "secretive"
      "shottr"
      "spotify"
      "tailscale-app"
      "thaw"
      "visual-studio-code"
      "zen"
      "aerospace"
      "docker/tap/sbx"
      "dimentium/autoraise/autoraiseapp"
    ];

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
      extraFlags = [ "--force" ];
    };
  };
}
