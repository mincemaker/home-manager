{ pkgs, lib, config, noctalia-shell, ... }:

let
  cfg = config.programs.niri;
  niriModuleDir = "${config.home.homeDirectory}/.config/home-manager/modules/niri";
  shellConfig = if cfg.shell == "noctalia"
    then import ./shells/noctalia.nix { inherit pkgs noctalia-shell; }
    else import ./shells/inir.nix { inherit pkgs; };
in {
  options.programs.niri = {
    enable = lib.mkEnableOption "niri compositor";
    shell = lib.mkOption {
      type = lib.types.enum [ "noctalia" "inir" ];
      default = "noctalia";
      description = "Which shell to use with niri (noctalia or inir)";
    };
    lockCommand = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      description = "Lock screen command derived from the selected shell configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.niri.lockCommand = shellConfig.lockCommand;

    home.packages = [ pkgs.niri ];

    # 選択されたシェルを自動的に有効化
    programs.noctalia-shell.enable = lib.mkDefault (cfg.shell == "noctalia");
    programs.inir.enable = lib.mkDefault (cfg.shell == "inir");

    home.activation.niriConfig = lib.hm.dag.entryAfter ["linkGeneration"] ''
      mkdir -p "$HOME/.config/niri"
      install -m 644 "${niriModuleDir}/config.kdl" "$HOME/.config/niri/config.kdl"
    '';
  };
}
