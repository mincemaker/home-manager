{ pkgs, lib, ... }:

{
  imports = [
    ../modules/agent-skills.nix
    ../modules/macskk.nix
    ../modules/yaskkserv2.nix
    ../modules/plamo-translate.nix
    ./common.nix
  ];

  programs = {
    git = {
      ignores = [
        ".DS_Store"
        "**/.claude/settings.local.json"
        "**/z-ai"
        ".env"
        ".serena/"
      ];
      package = null;
    };
    plamo-translate.enable = true;
    home-manager.enable = true;
    zsh.initContent = ''
      export CLICOLOR=1
      export LSCOLORS=exfxcxdxbxegedabagacad
      export GPG_TTY=$(tty)
      export SSH_AUTH_SOCK="$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
    '';
  };

  services.mpd = {
    enable = true;
    musicDirectory = "/Volumes/Music";
    extraConfig = ''
      audio_output {
        type "osx"
        name "CoreAudio"
      }
    '';
  };

  # home-manager の launchd 用 mpd エージェントは systemd 版と違い
  # ExecStartPre で dataDir/playlistDirectory を作成しないため、
  # 初回起動時に "No such file or directory" で失敗する。
  home.activation.mpdDataDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p $VERBOSE_ARG "$HOME/.local/share/mpd/playlists"
    $DRY_RUN_CMD mkdir -p $VERBOSE_ARG "$HOME/Library/Logs/mpd"
  '';

  launchd.agents.paneru = {
    enable = true;
    config = {
      ProgramArguments = [ "/opt/homebrew/bin/paneru" ];
      KeepAlive = true;
      RunAtLoad = true;
      ProcessType = "Interactive";
      LimitLoadToSessionType = "Aqua";
      StandardOutPath = "/Users/mince/Library/Logs/paneru.out.log";
      StandardErrorPath = "/Users/mince/Library/Logs/paneru.err.log";
    };
  };

  home = {
    packages = [ pkgs.cliamp ];

    username = "mince";
    homeDirectory = "/Users/mince";
    stateVersion = "25.11";
    file.".gnupg/gpg-agent.conf".text = ''
      pinentry-program /opt/homebrew/bin/pinentry-mac
    '';
  };
}
