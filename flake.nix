{
  description = "Home Manager configuration of mince";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Linux only
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

    cage = {
      url = "github:Warashi/cage";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    guard-and-guide = {
      url = "github:kawarimidoll/guard-and-guide";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 共通
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
    agent-browser = {
      url = "github:vercel-labs/agent-browser";
      flake = false;
    };
    awesome-copilot = {
      url = "github:github/awesome-copilot";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, home-manager, nix-darwin, ... } @ inputs:
    {
      # Linux: standalone home-manager (CachyOS)
      homeConfigurations."mince" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages."x86_64-linux";
        modules = [
          inputs.xremap-flake.homeManagerModules.default
          inputs.agent-skills.homeManagerModules.default
          ./modules/agent-skills.nix
          ./home/linux.nix
        ];
        extraSpecialArgs = {
          inherit (inputs) zen-browser noctalia-shell inir slash-criticalthink anthropic-skills agent-browser awesome-copilot cage guard-and-guide;
        };
      };

      # macOS: nix-darwin (home-managerを内包)
      darwinConfigurations."mince-mac" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [ ./nix-darwin/default.nix ];
        specialArgs = { inherit inputs; };
      };
    };
}
