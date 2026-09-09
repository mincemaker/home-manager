{ pkgs, arto, ... }:

{
  home.packages = [
    # rustc の LLVM 並列 codegen ワーカースレッドがデフォルトの
    # スタックサイズでは足りず SIGABRT/SIGSEGV で落ちることがあるため増やす
    (arto.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      RUST_MIN_STACK = "67108864";
    }))
  ];
}
