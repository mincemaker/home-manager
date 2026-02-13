{ pkgs }:

{
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
            duration-ms 400
            curve "linear"
            custom-shader r"
              vec4 pixelate_open(vec3 coords_geo, vec3 size_geo) {
                  // Discard pixels outside window bounds
                  if (coords_geo.x < 0.0 || coords_geo.x > 1.0 || coords_geo.y < 0.0 || coords_geo.y > 1.0) {
                      return vec4(0.0);
                  }
                  float progress = niri_clamped_progress;
                  float border_width = 0.008; // Adjust based on your border size
                  vec2 coords = coords_geo.xy;
                  // Check if we're in the border region
                  bool in_border = coords.x < border_width || coords.x > (1.0 - border_width) ||
                                  coords.y < border_width || coords.y > (1.0 - border_width);
                  // Only pixelate the inner content, not the border
                  if (!in_border) {
                      float pixel_size = (1.0 - progress) * 0.1;
                      if (pixel_size > 0.0) {
                          coords = floor(coords / pixel_size) * pixel_size + pixel_size * 0.5;
                      }
                      // Clamp sampling to avoid border area
                      coords = clamp(coords, border_width, 1.0 - border_width);
                  }
                  vec3 new_coords = vec3(coords, 1.0);
                  vec3 coords_tex = niri_geo_to_tex * new_coords;
                  vec4 color = texture2D(niri_tex, coords_tex.st);
                  color.a *= progress;
                  return color;
              }
              vec4 open_color(vec3 coords_geo, vec3 size_geo) {
                return pixelate_open(coords_geo, size_geo);
              }
            "
        }
        window-close {
            duration-ms 400
            curve "linear"
            custom-shader r"
              vec4 pixelate_close(vec3 coords_geo, vec3 size_geo) {
                  // Discard pixels outside window bounds
                  if (coords_geo.x < 0.0 || coords_geo.x > 1.0 || coords_geo.y < 0.0 || coords_geo.y > 1.0) {
                      return vec4(0.0);
                  }
                  float progress = niri_clamped_progress;
                  float border_width = 0.008;
                  vec2 coords = coords_geo.xy;
                  // Check if we're in the border region
                  bool in_border = coords.x < border_width || coords.x > (1.0 - border_width) ||
                                  coords.y < border_width || coords.y > (1.0 - border_width);
                  // Only pixelate the inner content, not the border
                  if (!in_border) {
                      float pixel_size = progress * 0.1;
                      if (pixel_size > 0.0) {
                          coords = floor(coords / pixel_size) * pixel_size + pixel_size * 0.5;
                      }
                      // Clamp sampling to avoid border area
                      coords = clamp(coords, border_width, 1.0 - border_width);
                  }
                  vec3 new_coords = vec3(coords, 1.0);
                  vec3 coords_tex = niri_geo_to_tex * new_coords;
                  vec4 color = texture2D(niri_tex, coords_tex.st);
                  color.a *= (1.0 - progress);
                  return color;
              }
              vec4 close_color(vec3 coords_geo, vec3 size_geo) {
                return pixelate_close(coords_geo, size_geo);
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

  commonStartup = pkgs: ''
    spawn-sh-at-startup "/usr/lib/polkit-kde-authentication-agent-1 &"
    spawn-sh-at-startup "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all"
  '';
}
