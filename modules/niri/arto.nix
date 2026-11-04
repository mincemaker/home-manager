{ pkgs, arto, ... }:

{
  home.packages = [
    arto.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
