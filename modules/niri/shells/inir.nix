{ pkgs }:

let
  shellCmd = "/usr/bin/qs -c ii";
  ipcLock = "lock activate";
in {
  binds = ''
    // ─── iNiR Controls ───
    MOD+Space   repeat=false hotkey-overlay-title="Overview" { spawn "qs" "-c" "ii" "ipc" "call" "overview" "toggle"; }
    MOD+G       hotkey-overlay-title="iNiR Overlay" { spawn "qs" "-c" "ii" "ipc" "call" "overlay" "toggle"; }
    MOD+SLASH   hotkey-overlay-title="Cheatsheet" { spawn "qs" "-c" "ii" "ipc" "call" "cheatsheet" "toggle"; }
    MOD+COMMA   hotkey-overlay-title="Settings" { spawn "qs" "-c" "ii" "ipc" "call" "settings" "open"; }
    MOD+V       hotkey-overlay-title="Clipboard" { spawn "qs" "-c" "ii" "ipc" "call" "clipboard" "toggle"; }
    MOD+Alt+L   hotkey-overlay-title="Lock Screen" { spawn "qs" "-c" "ii" "ipc" "call" "lock" "activate"; }
    ALT+TAB     hotkey-overlay-title="Window Switcher" { spawn "qs" "-c" "ii" "ipc" "call" "altSwitcher" "next"; }
    ALT+SHIFT+TAB hotkey-overlay-title="Window Switcher Prev" { spawn "qs" "-c" "ii" "ipc" "call" "altSwitcher" "previous"; }
    CTRL+ALT+T  hotkey-overlay-title="Wallpaper Selector" { spawn "qs" "-c" "ii" "ipc" "call" "wallpaperSelector" "toggle"; }
    MOD+SHIFT+S hotkey-overlay-title="Region Screenshot" { spawn "qs" "-c" "ii" "ipc" "call" "region" "screenshot"; }
    MOD+SHIFT+X hotkey-overlay-title="Region OCR" { spawn "qs" "-c" "ii" "ipc" "call" "region" "ocr"; }
    MOD+SHIFT+A hotkey-overlay-title="Region Search (Google Lens)" { spawn "qs" "-c" "ii" "ipc" "call" "region" "search"; }
    MOD+SHIFT+W hotkey-overlay-title="Cycle Panel Family" { spawn "qs" "-c" "ii" "ipc" "call" "panelFamily" "cycle"; }
    MOD+T       hotkey-overlay-title="Open Terminal" { spawn "ghostty"; }
    MOD+E       hotkey-overlay-title="File Manager: Dolphin" { spawn "dolphin"; }

    // ─── Window Management ───
    MOD+Q       repeat=false hotkey-overlay-title="Close Window" { spawn "bash" "-c" "$HOME/.config/quickshell/ii/scripts/close-window.sh"; }
    MOD+D       hotkey-overlay-title="Maximize Column" { maximize-column; }
    MOD+A       hotkey-overlay-title="Toggle Floating" { toggle-window-floating; }

    // ─── Audio Controls (iNiR IPC) ───
    XF86AudioRaiseVolume allow-when-locked=true { spawn "qs" "-c" "ii" "ipc" "call" "audio" "volumeUp"; }
    XF86AudioLowerVolume allow-when-locked=true { spawn "qs" "-c" "ii" "ipc" "call" "audio" "volumeDown"; }
    XF86AudioMute        allow-when-locked=true { spawn "qs" "-c" "ii" "ipc" "call" "audio" "mute"; }
    XF86AudioMicMute     allow-when-locked=true { spawn "qs" "-c" "ii" "ipc" "call" "audio" "micMute"; }
    XF86AudioNext        allow-when-locked=true { spawn "qs" "-c" "ii" "ipc" "call" "mpris" "next"; }
    XF86AudioPause       allow-when-locked=true { spawn "qs" "-c" "ii" "ipc" "call" "mpris" "playPause"; }
    XF86AudioPlay        allow-when-locked=true { spawn "qs" "-c" "ii" "ipc" "call" "mpris" "playPause"; }
    XF86AudioPrev        allow-when-locked=true { spawn "qs" "-c" "ii" "ipc" "call" "mpris" "previous"; }

    // ─── Music Control ───
    Ctrl+MOD+Space hotkey-overlay-title="Play/Pause" { spawn "qs" "-c" "ii" "ipc" "call" "mpris" "playPause"; }
    MOD+Alt+N      hotkey-overlay-title="Next Track" { spawn "qs" "-c" "ii" "ipc" "call" "mpris" "next"; }
    MOD+Alt+P      hotkey-overlay-title="Previous Track" { spawn "qs" "-c" "ii" "ipc" "call" "mpris" "previous"; }
  '';

  startup = pkgs: ''
    spawn-sh-at-startup "swww-daemon"
    spawn-sh-at-startup "swayidle -w timeout 900 '${shellCmd} ipc call ${ipcLock}' timeout 1800 'niri msg action power-off-monitors' before-sleep '${shellCmd} ipc call ${ipcLock}'"
    spawn-at-startup "${pkgs.wl-clipboard}/bin/wl-paste" "--watch" "${pkgs.cliphist}/bin/cliphist" "store"
    spawn-at-startup "${pkgs.wl-clipboard}/bin/wl-paste" "--type" "image" "--watch" "${pkgs.cliphist}/bin/cliphist" "store"
  '';

  layerRules = ''
    layer-rule {
        match namespace="quickshell:iiBackdrop"
        place-within-backdrop true
        opacity 1.0
    }

    layer-rule {
        match namespace="quickshell:wBackdrop"
        place-within-backdrop true
        opacity 1.0
    }
  '';
}
