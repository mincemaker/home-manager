{ pkgs }:

let
  shellCmd = "/usr/bin/qs -c inir";
  ipcLock = "lock activate";
in {
  lockCommand = "${shellCmd} ipc call ${ipcLock}";

  binds = ''
    // ─── iNiR Controls ───
    MOD+Space   repeat=false hotkey-overlay-title="Overview" { spawn "qs" "-c" "inir" "ipc" "call" "overview" "toggle"; }
    MOD+G       hotkey-overlay-title="iNiR Overlay" { spawn "qs" "-c" "inir" "ipc" "call" "overlay" "toggle"; }
    MOD+SLASH   hotkey-overlay-title="Cheatsheet" { spawn "qs" "-c" "inir" "ipc" "call" "cheatsheet" "toggle"; }
    MOD+COMMA   hotkey-overlay-title="Settings" { spawn "qs" "-c" "inir" "ipc" "call" "settings" "open"; }
    MOD+V       hotkey-overlay-title="Clipboard" { spawn "qs" "-c" "inir" "ipc" "call" "clipboard" "toggle"; }
    MOD+Alt+L   hotkey-overlay-title="Lock Screen" { spawn "qs" "-c" "inir" "ipc" "call" "lock" "activate"; }
    ALT+TAB     hotkey-overlay-title="Window Switcher" { spawn "rofi" "-show" "window"; }
    ALT+Space   hotkey-overlay-title="App Launcher" { spawn "rofi" "-show" "drun" "-terminal" "alacritty"; }
    ALT+SHIFT+TAB hotkey-overlay-title="Window Switcher Prev" { spawn "qs" "-c" "inir" "ipc" "call" "altSwitcher" "previous"; }
    CTRL+ALT+T  hotkey-overlay-title="Wallpaper Selector" { spawn "qs" "-c" "inir" "ipc" "call" "wallpaperSelector" "toggle"; }
    MOD+SHIFT+S hotkey-overlay-title="Region Screenshot" { spawn "qs" "-c" "inir" "ipc" "call" "region" "screenshot"; }
    MOD+SHIFT+X hotkey-overlay-title="Region OCR" { spawn "qs" "-c" "inir" "ipc" "call" "region" "ocr"; }
    MOD+SHIFT+A hotkey-overlay-title="Region Search (Google Lens)" { spawn "qs" "-c" "inir" "ipc" "call" "region" "search"; }
    MOD+SHIFT+W hotkey-overlay-title="Cycle Panel Family" { spawn "qs" "-c" "inir" "ipc" "call" "panelFamily" "cycle"; }
    MOD+T       hotkey-overlay-title="Open Terminal" { spawn "ghostty"; }
    MOD+E       hotkey-overlay-title="File Manager: Dolphin" { spawn "dolphin"; }

    // ─── Window Management ───
    MOD+Q       repeat=false hotkey-overlay-title="Close Window" { spawn "bash" "-c" "$HOME/.config/quickshell/inir/scripts/close-window.sh"; }
    MOD+D       hotkey-overlay-title="Maximize Column" { maximize-column; }
    MOD+A       hotkey-overlay-title="Toggle Floating" { toggle-window-floating; }

    // ─── Audio Controls (iNiR IPC) ───
    XF86AudioRaiseVolume allow-when-locked=true { spawn "qs" "-c" "inir" "ipc" "call" "audio" "volumeUp"; }
    XF86AudioLowerVolume allow-when-locked=true { spawn "qs" "-c" "inir" "ipc" "call" "audio" "volumeDown"; }
    XF86AudioMute        allow-when-locked=true { spawn "qs" "-c" "inir" "ipc" "call" "audio" "mute"; }
    XF86AudioMicMute     allow-when-locked=true { spawn "qs" "-c" "inir" "ipc" "call" "audio" "micMute"; }
    XF86AudioNext        allow-when-locked=true { spawn "qs" "-c" "inir" "ipc" "call" "mpris" "next"; }
    XF86AudioPause       allow-when-locked=true { spawn "qs" "-c" "inir" "ipc" "call" "mpris" "playPause"; }
    XF86AudioPlay        allow-when-locked=true { spawn "qs" "-c" "inir" "ipc" "call" "mpris" "playPause"; }
    XF86AudioPrev        allow-when-locked=true { spawn "qs" "-c" "inir" "ipc" "call" "mpris" "previous"; }

    // ─── Music Control ───
    Ctrl+MOD+Space hotkey-overlay-title="Play/Pause" { spawn "qs" "-c" "inir" "ipc" "call" "mpris" "playPause"; }
    MOD+Alt+N      hotkey-overlay-title="Next Track" { spawn "qs" "-c" "inir" "ipc" "call" "mpris" "next"; }
    MOD+Alt+P      hotkey-overlay-title="Previous Track" { spawn "qs" "-c" "inir" "ipc" "call" "mpris" "previous"; }
  '';

  startup = pkgs: ''
    spawn-sh-at-startup "awww-daemon"
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
