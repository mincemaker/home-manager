{
  description = "Home Manager configuration of mince";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia-shell = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    inir = {
      url = "github:snowarch/iNiR";
      flake = false;
    };
    xremap-flake.url = "github:xremap/nix-flake";
    stasis = {
      url = "github:saltnpepper97/stasis";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, zen-browser, noctalia-shell, inir, xremap-flake, stasis, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."mince" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          xremap-flake.homeManagerModules.default
          stasis.homeModules.default
          ./home.nix
        ];
        extraSpecialArgs = { inherit zen-browser noctalia-shell inir stasis; };
      };
    };
}
