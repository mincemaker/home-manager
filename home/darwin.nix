{ ... }:

{
  imports = [
    ../modules/agent-skills.nix
    ../modules/macskk.nix
    ../modules/yaskkserv2.nix
    ../modules/plamo-translate.nix
    ./common.nix
  ];

  programs.plamo-translate.enable = true;

  home.username = "mince";
  home.homeDirectory = "/Users/mince";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program /opt/homebrew/bin/pinentry-mac
  '';

  programs.zsh.initContent = ''
    export CLICOLOR=1
    export LSCOLORS=exfxcxdxbxegedabagacad
    export GPG_TTY=$(tty)
    export SSH_AUTH_SOCK="$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
  '';
}
