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
    xremap-flake.url = "github:xremap/nix-flake";
  };

  outputs =
    { nixpkgs, home-manager, zen-browser, xremap-flake, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."mince" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          xremap-flake.homeManagerModules.default
          ./home.nix
        ];
        extraSpecialArgs = { inherit zen-browser; };
      };
    };
}
