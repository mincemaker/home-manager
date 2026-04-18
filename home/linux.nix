{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
    ../modules/yaskkserv2.nix
    ../modules/niri/xremap.nix
    ../modules/niri/clock-rs.nix
    ../modules/niri/zen-browser.nix
    ../modules/niri
    ../modules/niri/noctalia-shell.nix
    ../modules/niri/inir.nix
  ];

  home.username = "mince";
  home.homeDirectory = "/home/mince";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.packages = [ pkgs.delta ];

  programs.fish = {
    enable = true;

    shellInit = ''
      fish_add_path $HOME/.local/bin
      fish_add_path $HOME/go/bin
      if test -d $HOME/.cargo/bin
          fish_add_path $HOME/.cargo/bin
      end
      fish_add_path $HOME/.lmstudio/bin
    '';

    interactiveShellInit = ''
      if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
          source /usr/share/cachyos-fish-config/cachyos-config.fish
      end

      if test -f ~/.config/fish/aliases.fish
          source ~/.config/fish/aliases.fish
      end

      set -x GPG_TTY (tty)
      set -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
      gpgconf --launch gpg-agent

      set -g fish_history_ignore_duplicates 1
      set -g fish_history_ignore_space 1
    '';

    shellAliases = {
      ls = "ls --color=auto";
    };
  };

  programs.zsh.shellAliases = {
    ls = "ls --color=auto";
  };

  programs.niri = {
    enable = true;
    shell = "inir";
  };

  programs.claude.enable = true;
}
