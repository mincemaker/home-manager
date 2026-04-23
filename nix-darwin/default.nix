{ inputs, pkgs, ... }:

{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    ./homebrew.nix
  ];

  home-manager = {
    backupFileExtension = "backup";
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [
      inputs.agent-skills.homeManagerModules.default
    ];
    extraSpecialArgs = {
      inherit (inputs) slash-criticalthink anthropic-skills cage guard-and-guide;
    };
    users.mince = ../home/darwin.nix;
  };

  users.users.mince = {
    name = "mince";
    home = "/Users/mince";
  };

  system.primaryUser = "mince";

  nix.enable = false;
  system.stateVersion = 5;
}
