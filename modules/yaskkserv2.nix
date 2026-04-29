{ pkgs, lib, config, ... }:

let
  jawikiDict = pkgs.fetchurl {
    url = "https://github.com/tokuhirom/jawiki-kana-kanji-dict/releases/download/v2026.04.01.141931/SKK-JISYO.jawiki";
    hash = "sha256-Dt1zExGVR7MZVYjDaDDqKYn2gq1EzJDx0wG5rXyYtTw=";
  };

  yaskkserv2 = pkgs.rustPlatform.buildRustPackage {
    pname = "yaskkserv2";
    version = "0.1.7";

    src = pkgs.fetchFromGitHub {
      owner = "wachikun";
      repo = "yaskkserv2";
      rev = "0.1.7";
      hash = "sha256-bF8OHP6nvGhxXNvvnVCuOVFarK/n7WhGRktRN4X5ZjE=";
    };

    cargoHash = "sha256-cycs8Zism228rjMaBpNYa4K1Ll760UhLKkoTX6VJRU0=";

    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.openssl ];

    doCheck = false;
  };

  logDir = "${config.home.homeDirectory}/.local/share/yaskkserv2";

  yaskDict = pkgs.runCommand "yaskkserv2-dictionary" { } ''
    mkdir -p $out
    ${yaskkserv2}/bin/yaskkserv2_make_dictionary \
      --dictionary-filename=$out/dictionary.yaskkserv2 \
      ${pkgs.skkDictionaries.l}/share/skk/SKK-JISYO.L \
      ${pkgs.skkDictionaries.jinmei}/share/skk/SKK-JISYO.jinmei \
      ${pkgs.skkDictionaries.zipcode}/share/skk/SKK-JISYO.zipcode \
      ${pkgs.skkDictionaries.geo}/share/skk/SKK-JISYO.geo \
      ${jawikiDict}
  '';
in
{
  home.packages = [ yaskkserv2 ];

  launchd.agents.yaskkserv2 = lib.mkIf pkgs.stdenv.isDarwin {
    enable = true;
    config = {
      Label = "com.github.wachikun.yaskkserv2";
      ProgramArguments = [
        "${yaskkserv2}/bin/yaskkserv2"
        "--no-daemonize"
        "--google-japanese-input=notfound"
        "--google-suggest"
        "${yaskDict}/dictionary.yaskkserv2"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      StandardOutPath = "${logDir}/yaskkserv2.log";
      StandardErrorPath = "${logDir}/yaskkserv2.err";
    };
  };

  systemd.user.services.yaskkserv2 = lib.mkIf pkgs.stdenv.isLinux {
    Unit.Description = "yaskkserv2 SKK server";
    Install.WantedBy = [ "default.target" ];
    Service = {
      ExecStart = "${yaskkserv2}/bin/yaskkserv2 --no-daemonize --google-japanese-input=notfound --google-suggest ${yaskDict}/dictionary.yaskkserv2";
      Restart = "on-failure";
    };
  };
}
