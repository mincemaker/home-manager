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
    slash-criticalthink = {
      url = "github:abagames/slash-criticalthink";
      flake = false;
    };
    agent-skills = {
      url = "github:Kyure-A/agent-skills-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    anthropic-skills = {
      url = "github:anthropics/skills";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, home-manager, zen-browser, noctalia-shell, inir, xremap-flake, slash-criticalthink, agent-skills, anthropic-skills, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."mince" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          xremap-flake.homeManagerModules.default
          agent-skills.homeManagerModules.default
          ./modules/agent-skills.nix
          ./home.nix
        ];
        extraSpecialArgs = { inherit zen-browser noctalia-shell inir slash-criticalthink anthropic-skills; };
      };
    };
}
