_:

{
  homebrew = {
    enable = true;

    taps = [
      { name = "FelixKratz/formulae"; trusted = true; }
      { name = "docker/tap"; trusted = true; }
      { name = "bjarneo/cliamp"; trusted = true;}
      { name = "sheeki03/tap"; trusted = true; }
    ];

    brews = [
      "bat"
      "btop"
      "cliamp"
      "ffmpeg"
      "flac"
      "libogg"
      "libvorbis"
      "yt-dlp"
      "clock-rs"
      "eza"
      "git-delta"
      "fd"
      "gh"
      "gmp"
      "gnupg"
      "lazygit"
      "media-control"
      "mise"
      "libyaml"
      "neovim"
      "openssl@3"
      "paneru"
      "pinentry-mac"
      "readline"
      "ripgrep"
      "tirith"
      { name = "sketchybar"; restart_service = "changed"; }
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
      "docker/tap/sbx"
    ];

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap";
      extraFlags = [ "--force" ];
    };
  };
}
