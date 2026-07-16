{ pkgs, ... }:

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

  launchd.agents.autoraise = {
    enable = true;
    config = {
      ProgramArguments = [
        "/Applications/AutoRaise.app/Contents/MacOS/AutoRaise"
        "-delay" "1"
        "-disableKey" "control"
        "-warpX" "0.5"
        "-warpY" "0.5"
        "-focusDelay" "1"
        "-requireMouseStop" "false"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      ProcessType = "Background";
      LimitLoadToSessionType = "Aqua";
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
