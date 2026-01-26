{ pkgs, noctalia-shell }:

let
  shellCmd = "/usr/bin/qs -p ${noctalia-shell.packages.${pkgs.system}.default}/share/noctalia-shell";
  ipcLauncher = "launcher toggle";
  ipcLock = "lockScreen lock";
in {
  lockCommand = "${shellCmd} ipc call ${ipcLock}";

  binds = ''
    // ─── noctalia-shell Controls ───
    MOD+SPACE   hotkey-overlay-title="App Launcher" { spawn-sh "${shellCmd} ipc call ${ipcLauncher}"; }
    MOD+SLASH   hotkey-overlay-title="App Launcher" { spawn-sh "${shellCmd} ipc call ${ipcLauncher}"; }
    ALT+TAB     hotkey-overlay-title="Window Switcher" { spawn "rofi" "-show" "window"; }
    Mod+Alt+L   hotkey-overlay-title="Lock Screen" { spawn-sh "${shellCmd} ipc call ${ipcLock}"; }
    MOD+E       hotkey-overlay-title="File Manager: Nautilus" { spawn "nautilus"; }

    // ─── Window Management ───
    MOD+Q                               { close-window; }
    MOD+T                               { toggle-window-floating; }

    // ─── Audio Controls (wpctl) ───
    XF86AudioRaiseVolume                allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+"; }
    XF86AudioLowerVolume                allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; }
    XF86AudioMute                       allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
    XF86AudioMicMute                    allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }
    XF86AudioNext                       allow-when-locked=true { spawn-sh "playerctl next"; }
    XF86AudioPause                      allow-when-locked=true { spawn-sh "playerctl play-pause"; }
    XF86AudioPlay                       allow-when-locked=true { spawn-sh "playerctl play-pause"; }
    XF86AudioPrev                       allow-when-locked=true { spawn-sh "playerctl previous"; }
  '';

  startup = ''
    spawn-sh-at-startup "swww-daemon"
    spawn-sh-at-startup "swww img /usr/share/wallpapers/cachyos-wallpapers/Skyscraper.png"
  '';

  layerRules = "";
}
