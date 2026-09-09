{ pkgs, arto, ... }:

let
  artoPkg = arto.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
    # rustc の LLVM 並列 codegen ワーカースレッドがデフォルトの
    # スタックサイズでは足りず SIGABRT/SIGSEGV で落ちることがあるため増やす
    RUST_MIN_STACK = "67108864";
  });

  # non-NixOS (CachyOS + NVIDIA proprietary driver) 環境では、
  # nixpkgs の Mesa とホストの NVIDIA カーネルモジュール/ドライバの不一致により
  # WebKitGTK が `Could not create default EGL display: EGL_BAD_PARAMETER` で失敗する。
  # ホストドライバと同じバージョンの NVIDIA EGL/GLVND ライブラリパスを渡してラップする。
  nvidiaVersion = "610.57.04";
  nvidiaHash = "sha256-suk1xmuDuwDAyFe8jg7g/VLekoa0DJzB7sKafOfrEW0=";

  nvidiaLibsOnly = (pkgs.linuxPackages.nvidia_x11.override {
    libsOnly = true;
  }).overrideAttrs (oldAttrs: {
    pname = "nvidia";
    name = "nvidia-x11-${nvidiaVersion}-nixGL";
    version = nvidiaVersion;
    src = pkgs.fetchurl {
      url = "https://download.nvidia.com/XFree86/Linux-x86_64/${nvidiaVersion}/NVIDIA-Linux-x86_64-${nvidiaVersion}.run";
      hash = nvidiaHash;
    };
    useGLVND = true;
  });

  artoWrapped = pkgs.symlinkJoin {
    name = "arto-${artoPkg.version or "wrapped"}";
    paths = [ artoPkg ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/arto \
        --prefix __EGL_VENDOR_LIBRARY_FILENAMES : "${nvidiaLibsOnly}/share/glvnd/egl_vendor.d/10_nvidia.json" \
        --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [ pkgs.libglvnd nvidiaLibsOnly ]}"
    '';
  };
in
{
  home.packages = [
    artoWrapped
  ];
}
