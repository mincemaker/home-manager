{ config, lib, pkgs, ... }:

let
  cfg = config.programs.tmux-config;
in {
  options.programs.tmux-config = {
    enable = lib.mkEnableOption "tmux with mincemaker config";
  };

  config = lib.mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      prefix = "C-z";
      keyMode = "vi";
      mouse = true;
      terminal = "tmux-256color";
      historyLimit = 50000;
      escapeTime = 10;
      baseIndex = 1;
      focusEvents = true;
      extraConfig = ''
        set -g prefix2 C-b
        set -g status-keys emacs
        set -g repeat-time 1000
        set -s extended-keys on
        set -ga terminal-overrides ",xterm-256color:Tc"
        set -g set-clipboard on

        set -g pane-base-index 1
        set -g renumber-windows on
        setw -g automatic-rename off

        set -g status-interval 5
        set -g status-left-length 20
        set -g status-right-length 60
        set -g status-style                 "bg=black,fg=white"
        set -g status-left                  "#[fg=cyan,bold][#H:#S]#[default] "
        set -g status-right                 "#[fg=magenta,bold]#{?#{==:#{pane_current_command},load.sh},,#(load.sh)}#[default] |#[fg=green,bold] %a %m/%d %H:%M#[default]"
        set -g message-style                "bold,fg=white,bg=red"
        setw -g mode-style                  "bg=white,fg=black"
        setw -g window-status-style         "fg=white,bg=black"
        setw -g window-status-current-style "fg=green,bg=black,bold"
        setw -g window-status-format        " #I:#W "
        setw -g window-status-current-format " #I:#W "
        set -g pane-border-style            "fg=cyan,bg=default"
        set -g pane-active-border-style     "fg=green,bg=default"

        unbind l
        unbind ^C
        bind C-r source ~/.tmux.conf \; display "Reloaded!"
        bind -r C-n next-window
        bind    C-z last-window
        bind    ^A  last-window
        bind    c   new-window -c "#{pane_current_path}"
        bind 1 break-pane
        bind 2 split-window -v -c "#{pane_current_path}"
        bind 3 split-window -h -c "#{pane_current_path}"
        bind -r C-h resize-pane -L 6
        bind -r C-l resize-pane -R 6
        bind -r C-j resize-pane -D 6
        bind -r C-k resize-pane -U 6
        bind -r s swap-pane -U
        bind    k kill-pane
        bind    K kill-window
        bind    i display-panes
        bind    y copy-mode
        bind    p paste-buffer
        bind -T copy-mode-vi v   send -X begin-selection
        bind -T copy-mode-vi y   send -X copy-selection-and-cancel
        bind -T copy-mode-vi C-v send -X rectangle-toggle
        unbind A
        bind A command-prompt "rename-window %%"
        bind -r H select-layout main-vertical   \; swap-pane -s : -t 0 \; select-pane -t 0 \; resize-pane -R 9
        bind -r K select-layout main-horizontal \; swap-pane -s : -t 0 \; select-pane -t 0 \; resize-pane -D 18
        bind b display-popup -E \
          "tmux lsw | fzf --reverse | cut -d: -f1 | xargs -I{} tmux select-window -t {}"
        bind w choose-tree -Zw

        if-shell "command -v sesh >/dev/null 2>&1" {
          bind-key "T" run-shell "sesh connect \"$(
            sesh list --icons | fzf-tmux -p 80%,70% \
              --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
              --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
              --bind 'tab:down,btab:up' \
              --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
              --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
              --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
              --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
              --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
              --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
              --preview-window 'right:55%' \
              --preview 'sesh preview {}'
          )\""
        }
      '';
    };
  };
}
