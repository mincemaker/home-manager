{ pkgs, zen-browser, ... }:

let
  zen = zen-browser.packages.${pkgs.stdenv.hostPlatform.system};
  # youwen5/zen-browser-flake#22: 1.23.3b was pinned before the release asset was published
  unwrapped =
    if zen.zen-browser-unwrapped.version == "1.23.3b" then
      zen.zen-browser-unwrapped.override {
        hash = "sha256-uyBF0+IWVNQP6EElAJLurf0sH8gx7vtQkiJ3PIvcoUk=";
      }
    else
      zen.zen-browser-unwrapped;
in
{
  home.packages = [
    (pkgs.callPackage "${zen-browser}/zen-browser.nix" { zen-browser-unwrapped = unwrapped; })
  ];
}
