{ config, lib, ... }:

let
  cfg = config.programs.niri;
  # シェルに応じたロックコマンド
  lockCommand = if cfg.shell == "inir"
    then "/usr/bin/qs -c ii ipc call lock activate"
    else "/usr/bin/qs -p /run/current-system/sw/share/noctalia-shell ipc call lockScreen lock";
in {
  # stasis サービスを有効化（設定ファイルは xdg.configFile で管理）
  services.stasis.enable = true;

  # stasis が起動時に設定ファイルを上書きするため force = true が必要
  xdg.configFile."stasis/stasis.rune" = {
    force = true;
    text = ''
      @description "niri idle management"

      default:
        monitor_media true
        debounce_seconds 5

        lock_screen:
          timeout 600
          command "${lockCommand}"
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
