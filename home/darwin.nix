{ config, pkgs, lib, inputs, ... }:

let
  git-sign = "${inputs.nix-secure-enclave-key.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/nix-secure-enclave-key-git-sign";
  # ssh-keygen exits 0 with a broken signature when Touch ID is rejected, so check the signature before git uses it
  git-sign-checked = pkgs.writeShellScript "git-sign-checked" ''
    ${git-sign} "$@" || exit
    [ "$1 $2" = "-Y sign" ] || exit 0
    eval "file=\''${$#}"
    /usr/bin/ssh-keygen -Y check-novalidate -n git -s "$file.sig" < "$file" > /dev/null 2>&1 && exit 0
    rm -f "$file.sig"
    echo "error: signature is invalid; Touch ID was probably rejected" >&2
    exit 1
  '';
in
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
      package = null;
      signing.signer = lib.mkForce "${git-sign-checked}";
      settings.gpg.ssh = {
        allowedSignersFile = "~/.gitallowedsigners";
        program = lib.mkForce "${git-sign-checked}";
      };
    };
    nix-secure-enclave-key = {
      enable = true;
      identities.main = {
        keyFile = "~/.ssh/id_enclave_key";
        protection = "bio";
      };
      signingIdentity = "main";
    };
    # try init は $SHELL で構文を選ぶため、zsh から起動した fish では明示する。
    fish.shellInit = lib.mkForce ''
      eval (env SHELL=fish ${lib.getExe' config.programs.try.package "try"} init ${config.programs.try.path} | string collect)
    '';
    ssh.enable = false;
    plamo-translate.enable = true;
    home-manager.enable = true;
    zsh.initContent = ''
      export CLICOLOR=1
      export LSCOLORS=exfxcxdxbxegedabagacad
      export GPG_TTY=$(tty)
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
