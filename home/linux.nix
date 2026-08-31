{ pkgs, ... }:

{
  imports = [
    ./common.nix
    ../modules/yaskkserv2.nix
    ../modules/niri/xremap.nix
    ../modules/niri/clock-rs.nix
    ../modules/niri/zen-browser.nix
    ../modules/niri
    ../modules/niri/noctalia-shell.nix
  ];

  home = {
    username = "mince";
    homeDirectory = "/home/mince";
    stateVersion = "25.11";
    packages = with pkgs; [
      delta
      wl-clipboard
      cliphist
      (symlinkJoin {
        name = "cliamp";
        paths = [ cliamp ];
        nativeBuildInputs = [ makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/cliamp \
            --set ALSA_PLUGIN_DIR ${pipewire}/lib/alsa-lib
        '';
      })
    ];
  };

  programs = {
    home-manager.enable = true;

    fish = {
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

        if test -f ~/.config/fish/config.local.fish
            source ~/.config/fish/config.local.fish
        end

        set -x GPG_TTY (tty)
        set -x SSH_AUTH_SOCK (gpgconf --list-dirs agent-ssh-socket)
        gpgconf --launch gpg-agent

        set -g fish_history_ignore_duplicates 1
        set -g fish_history_ignore_space 1
      '';

      shellAliases = {
        ls = "LC_ALL=C ls --color=auto";
      };

      # tirith の fish フックは umask 077 を復元しないバグがあり
      # (fish の (...) は本物のサブシェルではないため tirith 側のパターンが機能しない)、
      # 対話シェルの umask が恒久的に汚染される。汚染値は _tirith_v3_new_capture_file の
      # ハードコードで必ず 0077 固定なので、umask が 0077 のときだけ直近の既知良好値へ
      # 戻す。毎コマンド実行後に既知良好値を実際の umask で更新し続けるため、ユーザーが
      # 対話シェルで umask を手動変更してもそのまま尊重・継続される
      # (0077 を意図的に使い続けたい場合も、その値が既知良好値として上書きされるので
      # 実害はない)。有効化は各マシンの ~/.config/fish/config.local.fish 側で行う。
      #
      # __tirith_umask_guard_resync が既知良好値として 0077 をそのまま記録してしまう
      # 余地は、tirith が fish_preexec/fish_postexec 等のイベントで汚染するように
      # なった場合にのみ生じる (現行の tirith 0.4.0 は Enter キーへの直接バインドの
      # 中だけで同期的に汚染するため該当しない。fish-hook.fish 全体で --on-event は
      # 一切使われていないことをソースで確認済み)。tirith 側の実装が変わった場合は
      # この前提を再確認すること。
      #
      # __tirith_umask_guard / __tirith_umask_guard_resync は tirith-umask-guard-enable
      # の呼び出し時にネストして定義する。fish は --on-event 付き関数を functions/
      # ディレクトリに置くだけで呼び出しの有無に関わらずシェル起動時に登録してしまう
      # ため、独立した autoload 関数として置くと有効化していないマシンでも毎コマンド
      # 前後に umask ビルトインが素通しで実行され余計な出力が出る。呼び出し時定義に
      # することで未有効化のマシンでは関数自体が一切登録されない。
      functions.tirith-umask-guard-enable = ''
        if not set -q __tirith_umask_guard_last_good
          set -g __tirith_umask_guard_last_good (umask)
        end
        function __tirith_umask_guard --on-event fish_preexec
          if test (umask) = 0077
            umask $__tirith_umask_guard_last_good
          end
        end
        function __tirith_umask_guard_resync --on-event fish_postexec
          set -g __tirith_umask_guard_last_good (umask)
        end
      '';
    };

    zsh.shellAliases = {
      ls = "LC_ALL=C ls --color=auto";
    };

    niri = {
      enable = true;
      shell = "inir";
    };

    claude.enable = true;
  };
}
