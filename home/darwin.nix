{ ... }:

{
  imports = [
    ../modules/autoraise.nix
    ../modules/agent-skills.nix
    ../modules/macskk.nix
    ../modules/yaskkserv2.nix
    ../modules/plamo-translate.nix
    ./common.nix
  ];

  programs = {
    plamo-translate.enable = true;
    home-manager.enable = true;
    zsh.initContent = ''
      export CLICOLOR=1
      export LSCOLORS=exfxcxdxbxegedabagacad
      export GPG_TTY=$(tty)
      export SSH_AUTH_SOCK="$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
    '';
  };

  home = {
    username = "mince";
    homeDirectory = "/Users/mince";
    stateVersion = "25.11";
    file.".gnupg/gpg-agent.conf".text = ''
      pinentry-program /opt/homebrew/bin/pinentry-mac
    '';
  };
}
