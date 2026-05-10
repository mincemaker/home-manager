{ pkgs, lib, config, noctalia-shell, ... }:

let
  cfg = config.programs.niri;
  shellConfig = if cfg.shell == "noctalia"
    then import ./shells/noctalia.nix { inherit pkgs noctalia-shell; }
    else import ./shells/inir.nix { inherit pkgs; };
  shellStartup = if cfg.shell == "inir"
    then shellConfig.startup pkgs
    else shellConfig.startup;

  input = ''
    input {
        keyboard {
            xkb {
                layout "us"
            }
            numlock
        }

        touchpad {
            tap
            natural-scroll
        }

        focus-follows-mouse
        workspace-auto-back-and-forth
    }
  '';

  output = ''
    /- output "DP-1" {
        mode "2560x1440@359.979"
        scale 1
    }

    output "DP-1" {
        position x=0 y=0
        mode "3440x1440@179.989"
    }

    output "DP-2" {
        position x=3440 y=0
        mode "1920x1080@239.760"
        focus-at-startup
    }

    output "HDMI-A-1" {
        position x=5360 y=0
        mode "640x480@60"
    }
  '';

  layout = ''
    layout {
        gaps 16
        center-focused-column "never"

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        focus-ring {
            width 3
            active-color "#00ac89"
            inactive-color "#505050"
        }

        shadow {
            softness 30
            spread 5
            offset x=0 y=5
            color "#0007"
        }

        struts {}
    }
  '';

  animations = ''
    animations {
        workspace-switch {
            duration-ms 300
            curve "ease-out-cubic"
        }
        window-open {
            duration-ms 1500
            curve "ease-out-cubic"
            custom-shader r"
              // Ported from skwd-wall ink-splash transition

              float is_hash(vec2 p) {
                  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
              }

              float is_noise(vec2 p) {
                  vec2 i = floor(p);
                  vec2 f = fract(p);
                  f = f * f * (3.0 - 2.0 * f);
                  return mix(mix(is_hash(i), is_hash(i + vec2(1.0, 0.0)), f.x),
                             mix(is_hash(i + vec2(0.0, 1.0)), is_hash(i + vec2(1.0, 1.0)), f.x), f.y);
              }

              float is_fbm(vec2 p) {
                  float v = 0.0;
                  float amp = 0.5;
                  for (int i = 0; i < 5; i++) {
                      v += amp * is_noise(p);
                      p *= 2.1;
                      amp *= 0.5;
                  }
                  return v;
              }

              vec4 open_color(vec3 coords_geo, vec3 size_geo) {
                  float p = niri_clamped_progress;
                  vec2 uv = coords_geo.xy;
                  vec3 tc = niri_geo_to_tex * vec3(uv, 1.0);
                  vec4 win = texture2D(niri_tex, tc.st);

                  float blob = is_fbm(uv * 3.5);
                  float fingers = is_fbm(uv * 14.0);
                  float distortion = (blob - 0.5) * 0.5 + (fingers - 0.5) * 0.18;
                  vec2 c = uv - vec2(0.5);
                  c.x *= size_geo.x / max(size_geo.y, 0.0001);
                  float d = length(c);
                  float splash_d = d + distortion;
                  float boundary = p * 1.7 - 0.15;
                  float diff = splash_d - boundary;
                  float reveal = smoothstep(0.04, -0.04, diff);

                  return win * reveal;
              }
            "
        }
        window-close {
            duration-ms 1500
            curve "ease-out-cubic"
            custom-shader r"
              // Ported from skwd-wall ink-splash transition

              float is_hash(vec2 p) {
                  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
              }

              float is_noise(vec2 p) {
                  vec2 i = floor(p);
                  vec2 f = fract(p);
                  f = f * f * (3.0 - 2.0 * f);
                  return mix(mix(is_hash(i), is_hash(i + vec2(1.0, 0.0)), f.x),
                             mix(is_hash(i + vec2(0.0, 1.0)), is_hash(i + vec2(1.0, 1.0)), f.x), f.y);
              }

              float is_fbm(vec2 p) {
                  float v = 0.0;
                  float amp = 0.5;
                  for (int i = 0; i < 5; i++) {
                      v += amp * is_noise(p);
                      p *= 2.1;
                      amp *= 0.5;
                  }
                  return v;
              }

              vec4 close_color(vec3 coords_geo, vec3 size_geo) {
                  float p = 1.0 - niri_clamped_progress;
                  vec2 uv = coords_geo.xy;
                  vec3 tc = niri_geo_to_tex * vec3(uv, 1.0);
                  vec4 win = texture2D(niri_tex, tc.st);

                  float blob = is_fbm(uv * 3.5);
                  float fingers = is_fbm(uv * 14.0);
                  float distortion = (blob - 0.5) * 0.5 + (fingers - 0.5) * 0.18;
                  vec2 c = uv - vec2(0.5);
                  c.x *= size_geo.x / max(size_geo.y, 0.0001);
                  float d = length(c);
                  float splash_d = d + distortion;
                  float boundary = p * 1.7 - 0.15;
                  float diff = splash_d - boundary;
                  float reveal = smoothstep(0.04, -0.04, diff);

                  return win * reveal;
              }
            "
        }
        horizontal-view-movement {
            spring damping-ratio=1.0 stiffness=900 epsilon=0.0001
        }
        window-movement {
            spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
        }
        window-resize {
            spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001
        }
        config-notification-open-close {
            spring damping-ratio=0.6 stiffness=1200 epsilon=0.001
        }
        screenshot-ui-open {
            duration-ms 300
            curve "ease-out-quad"
        }
        overview-open-close {
            spring damping-ratio=1.0 stiffness=900 epsilon=0.0001
        }
    }
  '';

  windowRules = ''
    window-rule {
        match app-id=r#"firefox$"#
        opacity 0.8
        draw-border-with-background false
    }

    window-rule {
        match app-id=r#"firefox$"# title="^Picture-in-Picture$"
        open-floating true
    }

    window-rule {
        geometry-corner-radius 20
        clip-to-geometry true
    }
  '';

  environment = ''
    environment {
        DISPLAY ":1"
        ELECTRON_OZONE_PLATFORM_HINT "auto"
        QT_QPA_PLATFORM "wayland"
        QT_WAYLAND_DISABLE_WINDOWDECORATION "1"
        XDG_SESSION_TYPE "wayland"
        XDG_CURRENT_DESKTOP "niri"
    }
  '';

  misc = ''
    prefer-no-csd
    screenshot-path null

    hotkey-overlay {
        skip-at-startup
    }
  '';

  commonBinds = ''
    MOD+SHIFT+SLASH                     { show-hotkey-overlay; }

    // ─── Common Applications ───
    MOD+RETURN  hotkey-overlay-title="Open Terminal" { spawn "ghostty"; }
    MOD+B       hotkey-overlay-title="Open Browser: firefox" { spawn "firefox"; }

    // ─── Window Movement and Focus ───
    MOD+LEFT                            { focus-column-left; }
    MOD+H                               { focus-column-or-monitor-left; }
    MOD+RIGHT                           { focus-column-right; }
    MOD+L                               { focus-column-or-monitor-right; }
    MOD+UP                              { focus-window-up; }
    MOD+K                               { focus-window-up; }
    MOD+DOWN                            { focus-window-down; }
    MOD+J                               { focus-window-down; }

    MOD+CTRL+LEFT                       { move-column-left; }
    MOD+CTRL+H                          { move-column-left; }
    MOD+CTRL+RIGHT                      { move-column-right; }
    MOD+CTRL+L                          { move-column-right; }
    MOD+CTRL+UP                         { move-window-up; }
    MOD+CTRL+K                          { move-window-up; }
    MOD+CTRL+DOWN                       { move-window-down; }
    MOD+CTRL+J                          { move-window-down; }

    MOD+HOME                            { focus-column-first; }
    MOD+END                             { focus-column-last; }
    MOD+CTRL+HOME                       { move-column-to-first; }
    MOD+CTRL+END                        { move-column-to-last; }

    MOD+SHIFT+LEFT                      { focus-monitor-left; }
    MOD+SHIFT+RIGHT                     { focus-monitor-right; }
    MOD+SHIFT+UP                        { focus-monitor-up; }
    MOD+SHIFT+DOWN                      { focus-monitor-down; }

    MOD+SHIFT+CTRL+LEFT                 { move-column-to-monitor-left; }
    MOD+SHIFT+CTRL+H                    { move-column-to-monitor-left; }
    MOD+SHIFT+CTRL+RIGHT                { move-column-to-monitor-right; }
    MOD+SHIFT+CTRL+L                    { move-column-to-monitor-right; }
    MOD+SHIFT+CTRL+UP                   { move-column-to-monitor-up; }
    MOD+SHIFT+CTRL+K                    { move-column-to-monitor-up; }
    MOD+SHIFT+CTRL+DOWN                 { move-column-to-monitor-down; }
    MOD+SHIFT+CTRL+J                    { move-column-to-monitor-down; }

    // Shift + ホイールで横スクロール
    SHIFT+WHEELSCROLLDOWN                 cooldown-ms=50 { focus-column-right; }
    SHIFT+WHEELSCROLLUP                   cooldown-ms=50 { focus-column-left; }

    // ─── Workspace Switching ───
    MOD+WHEELSCROLLDOWN                 cooldown-ms=150 { focus-workspace-down; }
    MOD+WHEELSCROLLUP                   cooldown-ms=150 { focus-workspace-up; }
    MOD+CTRL+WHEELSCROLLDOWN            cooldown-ms=150 { move-column-to-workspace-down; }
    MOD+CTRL+WHEELSCROLLUP              cooldown-ms=150 { move-column-to-workspace-up; }

    MOD+WHEELSCROLLRIGHT                { focus-column-right; }
    MOD+WHEELSCROLLLEFT                 { focus-column-left; }
    MOD+CTRL+WHEELSCROLLRIGHT           { move-column-right; }
    MOD+CTRL+WHEELSCROLLLEFT            { move-column-left; }

    MOD+SHIFT+WHEELSCROLLDOWN           { focus-column-right; }
    MOD+SHIFT+WHEELSCROLLUP             { focus-column-left; }
    MOD+CTRL+SHIFT+WHEELSCROLLDOWN      { move-column-right; }
    MOD+CTRL+SHIFT+WHEELSCROLLUP        { move-column-left; }

    MOD+1                               { focus-workspace 1; }
    MOD+2                               { focus-workspace 2; }
    MOD+3                               { focus-workspace 3; }
    MOD+4                               { focus-workspace 4; }
    MOD+5                               { focus-workspace 5; }
    MOD+6                               { focus-workspace 6; }
    MOD+7                               { focus-workspace 7; }
    MOD+8                               { focus-workspace 8; }
    MOD+9                               { focus-workspace 9; }

    MOD+CTRL+1                          { move-column-to-workspace 1; }
    MOD+CTRL+2                          { move-column-to-workspace 2; }
    MOD+CTRL+3                          { move-column-to-workspace 3; }
    MOD+CTRL+4                          { move-column-to-workspace 4; }
    MOD+CTRL+5                          { move-column-to-workspace 5; }
    MOD+CTRL+6                          { move-column-to-workspace 6; }
    MOD+CTRL+7                          { move-column-to-workspace 7; }
    MOD+CTRL+8                          { move-column-to-workspace 8; }
    MOD+CTRL+9                          { move-column-to-workspace 9; }

    MOD+TAB                             { focus-workspace-previous; }

    // ─── Layout Controls ───
    MOD+CTRL+F                          { expand-column-to-available-width; }
    MOD+C                               { center-column; }
    MOD+CTRL+C                          { center-visible-columns; }
    MOD+MINUS                           { set-column-width "-10%"; }
    MOD+EQUAL                           { set-column-width "+10%"; }
    MOD+SHIFT+MINUS                     { set-window-height "-10%"; }
    MOD+SHIFT+EQUAL                     { set-window-height "+10%"; }
    MOD+M                               { switch-preset-column-width; }

    Mod+BracketLeft                     { consume-window-into-column; }
    Mod+BracketRight                    { expel-window-from-column; }

    // ─── Modes ───
    MOD+F                               { fullscreen-window; }
    MOD+W                               { toggle-column-tabbed-display; }

    // ─── Screenshots ───
    CTRL+SHIFT+1                        { screenshot; }
    CTRL+SHIFT+2                        { screenshot-screen; }
    CTRL+SHIFT+3                        { screenshot-window; }

    // ─── Emergency Escape Key ───
    MOD+ESCAPE                          allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }

    // ─── Exit / Power ───
    CTRL+ALT+DELETE                     { quit; }
    MOD+SHIFT+P                         { power-off-monitors; }
    MOD+O                               repeat=false { toggle-overview; }
  '';

  commonStartup = ''
    spawn-sh-at-startup "/usr/lib/polkit-kde-authentication-agent-1 &"
    spawn-sh-at-startup "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all"
    spawn-sh-at-startup "systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP && systemctl --user start graphical-session.target"
  '';

  niriConfig = pkgs.writeText "niri-config.kdl" ''
    ${input}

    ${output}

    binds {
    ${commonBinds}

    ${shellConfig.binds}
    }

    ${commonStartup}
    ${shellStartup}

    ${misc}

    ${layout}

    ${animations}

    ${windowRules}

    ${shellConfig.layerRules}

    ${environment}
  '';
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
      install -m 644 "${niriConfig}" "$HOME/.config/niri/config.kdl"
    '';
  };
}
