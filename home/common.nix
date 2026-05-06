{ config, lib, pkgs, ... }:

{
  imports = [
    ../modules/claude.nix
    ../modules/tmux.nix
    ../modules/cage.nix
    ../modules/guard-and-guide.nix
  ];

  programs.claude.enable = true;
  programs.tmux-config.enable = true;
  programs.cage.enable = true;
  programs.guard-and-guide.enable = true;

  home.packages = [
    pkgs.tealdeer
    pkgs.zsh-completions
    pkgs.nixd
    pkgs.nil
    pkgs.uv
  ];

  home.sessionVariables = {
    LANG = "ja_JP.UTF-8";
    EDITOR = "vim";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    defaultKeymap = "emacs";

    completionInit = ''
      autoload -Uz compinit
      if [[ -n ''${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
        compinit
      else
        compinit -C
      fi
    '';

    history = {
      path = "${config.home.homeDirectory}/.zsh_history";
      size = 1000000;
      save = 1000000;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      share = true;
      extended = true;
    };

    shellAliases = {
      where = "command -v";
      j = "jobs -l";
      la = "ls -a";
      ll = "ls -ltrAF";
      l = "ls -lh";
      du = "du -h";
      df = "df -h";
    };

    initContent = lib.mkMerge [
      ''
        setopt auto_menu auto_cd correct auto_name_dirs auto_remove_slash
        setopt extended_glob list_types no_beep always_last_prompt
        setopt auto_param_keys auto_pushd pushd_ignore_dups prompt_subst cdable_vars

        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
        zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
        setopt complete_aliases

        bindkey "^?" backward-delete-char
        bindkey "^H" backward-delete-char
        bindkey "^[[3~" delete-char
        [[ -n ''${terminfo[khome]} ]] && bindkey "''${terminfo[khome]}" beginning-of-line
        [[ -n ''${terminfo[kend]}  ]] && bindkey "''${terminfo[kend]}"  end-of-line

        autoload -Uz history-search-end
        zle -N history-beginning-search-backward-end history-search-end
        zle -N history-beginning-search-forward-end  history-search-end
        bindkey "^p" history-beginning-search-backward-end
        bindkey "^n" history-beginning-search-forward-end

        WORDCHARS="''${WORDCHARS:s,/,,}"

        zstyle ':fzf-tab:*' fzf-command fzf
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
      ''
      (lib.mkAfter ''
        [[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
      '')
    ];

    plugins = [
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
    ];
  };

  programs.carapace = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship.enable = true;

  programs.zoxide.enable = true;

  programs.fzf.enable = true;

  programs.mise.enable = true;

  programs.jujutsu = {
    enable = true;
    settings = {
      aliases = {
        tug = ["bookmark" "move" "--from" "heads(::@- & bookmarks())" "--to" "@-"];
      };
    };
  };
}
