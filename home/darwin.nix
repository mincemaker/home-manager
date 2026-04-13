{ ... }:

{
  imports = [
    ../modules/agent-skills.nix
    ../modules/macskk.nix
    ./common.nix
  ];

  home.username = "mince";
  home.homeDirectory = "/Users/mince";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.file.".gnupg/gpg-agent.conf".text = ''
    pinentry-program /opt/homebrew/bin/pinentry-mac
    enable-ssh-support
  '';

  programs.zsh.initContent = ''
    export CLICOLOR=1
    export LSCOLORS=exfxcxdxbxegedabagacad
  '';
}
