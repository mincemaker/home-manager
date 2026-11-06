{ pkgs, arto, ... }:

let
  artoPkg = arto.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  home.packages = [ artoPkg ];

  xdg.desktopEntries.arto = {
    name = "Arto";
    exec = "${artoPkg}/bin/arto %F";
    icon = "${arto}/crates/arto/assets/Arto.png";
    categories = [ "Utility" "TextTools" ];
    mimeType = [ "text/markdown" ];
  };
}
