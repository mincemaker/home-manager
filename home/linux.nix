{ config, lib, pkgs, llm-agents, ... }:

{
  imports = [
    ./common.nix
    ../modules/yaskkserv2.nix
    ../modules/niri/xremap.nix
    ../modules/niri/clock-rs.nix
    ../modules/niri/zen-browser.nix
    ../modules/niri/arto.nix
    ../modules/niri/iris/agent-usage.nix
  ];

  targets.genericLinux.gpu = {
    enable = true;
    nvidia = {
      enable = true;
      version = "620.73.04";
      sha256 = "sha256-tfLi1dqENbMlOTBAFbib9+si/grsjNaQW3puip+bjxs=";
    };
  };

  # 読み込み済みモジュールは pacman 更新後も再起動まで旧版のままなので、インストール済みパッケージと比べる
  home.activation.checkNvidiaVersionDrift = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
    host=$(/usr/bin/pacman -Q nvidia-utils 2>/dev/null || true)
    host=''${host#* }
    host=''${host%-*}
    want=${config.targets.genericLinux.gpu.nvidia.version}
    if [[ -n "$host" && "$host" != "$want" ]]; then
      errorEcho "Host nvidia-utils is $host but targets.genericLinux.gpu.nvidia.version is $want."
      errorEcho "Set version = \"$host\" in home/linux.nix and sha256 from:"
      errorEcho "  nix store prefetch-file https://download.nvidia.com/XFree86/Linux-x86_64/$host/NVIDIA-Linux-x86_64-$host.run"
      errorEcho "Then switch and rerun non-nixos-gpu-setup with sudo."
      exit 1
    fi
  '';

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
    ] ++ (with llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
      herdr-app
      # chatgpt.desktop は http/https のハンドラを名乗っており、名前順で zen より
      # 前に並ぶ。ホストの Firefox が見えない claude-desktop の FHS 環境では、
      # 認証リンクが ChatGPT で開いてしまうので、この 2 つだけ外す
      (pkgs.symlinkJoin {
        name = "chatgpt";
        paths = [ chatgpt ];
        postBuild = ''
          rm $out/share
          cp -rs ${chatgpt}/share/ $out/share
          chmod -R u+w $out/share
          rm $out/share/applications/chatgpt.desktop
          sed -E 's#x-scheme-handler/https?;##g' ${chatgpt}/share/applications/chatgpt.desktop \
            > $out/share/applications/chatgpt.desktop
        '';
      })
    ]);
  };

  # fish の interactiveShellInit だけでは systemd 経由で起動する hc の core に
  # 届かず、hc machine add の ssh が gpg-agent を使えない
  systemd.user.sessionVariables.SSH_AUTH_SOCK = "\${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.ssh";

  services.mpd = {
    enable = true;
    musicDirectory = "/mnt/music";
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "PipeWire"
      }
    '';
  };

  programs = {
    home-manager.enable = true;

    try.path = "/mnt/development/tries";

    foot = {
      enable = true;
      settings = {
        main = {
          shell = "fish";
          term = "xterm-256color";
          title = "foot";
          font = "Moralerspace Krypton HW:size=12";
          letter-spacing = 0;
          dpi-aware = "no";
          pad = "25x25";
          bold-text-in-bright = "no";
        };
        scrollback.lines = 10000;
        cursor = {
          style = "beam";
          blink = "no";
          beam-thickness = 1.5;
        };
        key-bindings = {
          scrollback-up-page = "Page_Up";
          scrollback-down-page = "Page_Down";
          font-increase = "Control+plus Control+equal Control+KP_Add";
          font-decrease = "Control+minus Control+KP_Subtract";
          font-reset = "Control+0 Control+KP_0";
        };
        search-bindings = {
          cancel = "Escape";
          find-prev = "Shift+F3";
          find-next = "F3 Control+G";
          delete-prev-word = "Control+BackSpace";
        };
      };
    };

    fish = {
      enable = true;
      shellAbbrs.ccu = "uvx ccusage; uvx codex-cli-usage";

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
    };

    zsh.shellAliases = {
      ls = "LC_ALL=C ls --color=auto";
    };
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [
        "Moralerspace Neon HW"
        "Noto Sans Mono CJK JP"
      ];
      sansSerif = [
        "Noto Sans CJK JP"
        "DejaVu Sans"
      ];
      serif = [
        "Noto Serif CJK JP"
        "DejaVu Serif"
      ];
    };
  };
}
