{ config, lib, pkgs, ... }:

let
  cfg = config.programs.niri;
in {
  # stasis サービスを有効化（設定ファイルは xdg.configFile で管理）
  services.stasis.enable = true;

  # stasis が起動時に設定ファイルを上書きするため force = true が必要
  # stasis がアイドル管理を担当するため、inir 内蔵の swayidle を無効化
  home.activation.disableInirIdle = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    configFile="$HOME/.config/illogical-impulse/config.json"
    if [ -f "$configFile" ]; then
      ${pkgs.jq}/bin/jq '.idle.screenOffTimeout = 0 | .idle.lockTimeout = 0 | .idle.suspendTimeout = 0' \
        "$configFile" > "$configFile.tmp" && mv "$configFile.tmp" "$configFile"
    fi
  '';

  xdg.configFile."stasis/stasis.rune" = {
    force = true;
    text = ''
      @description "niri idle management"

      default:
        monitor_media true
        debounce_seconds 5

        lock_screen:
          timeout 600
          command "${cfg.lockCommand}"
        end

        dpms:
          timeout 1800
          command "niri msg action power-off-monitors"
          resume-command "niri msg action power-on-monitors"
        end

        suspend:
          timeout 7200
          command "systemctl suspend"
        end
      end
    '';
  };
}
