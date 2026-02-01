{ ... }:

{
  services.xremap = {
    enable = true;
    withWlroots = true;  # COSMIC用
    watch = true;
    deviceNames = [
      "SlimBlade Pro"
      "HHKB"
      "r47go"
      "foostan Corne v4"
      "Lofree"
      "HUGE PLUS HUGE PLUS"
    ];

    config.modmap = [
      {
        name = "SlimBladePro held";
        device.only = "SlimBlade Pro";
        remap = {
          BTN_SIDE = {
            held = "F24";
            alone = "BTN_RIGHT";
            alone_timeout_millis = 150;
          };
        };
      }
    ];

    config.keymap = [
      {
        name = "Emacs";
        application.not = [ "Emacs" "Ghostty" "ghostty" "Alacritty" "wezterm"];
        remap = {
          # Cursor
          "C-b" = { with_mark = "left"; };
          "C-f" = { with_mark = "right"; };
          "C-p" = { with_mark = "up"; };
          "C-n" = { with_mark = "down"; };
          # Forward/Backward word
          "M-b" = { with_mark = "C-left"; };
          "M-f" = { with_mark = "C-right"; };
          # Beginning/End of line
          "C-a" = { with_mark = "home"; };
          "C-e" = { with_mark = "end"; };
          # Page up
          "M-v" = { with_mark = "pageup"; };
          # Beginning/End of file
          "M-Shift-comma" = { with_mark = "C-home"; };
          "M-Shift-dot" = { with_mark = "C-end"; };
          # Newline
          "C-m" = "enter";
          "C-o" = [ "enter" "left" ];
          # Copy
          "C-w" = [ "C-x" { set_mark = false; } ];
          "M-w" = [ "C-c" { set_mark = false; } ];
          # Delete
          "C-h" = [ "backspace" { set_mark = false; } ];
          "Win-C-h" = "Win-C-h";
          "Win-C-l" = "Win-C-l";
          "Win-C-j" = "Win-C-j";
          "Win-C-k" = "Win-C-k";
          "Win-C-Shift-h" = "Win-C-Shift-h";
          "Win-C-Shift-l" = "Win-C-Shift-l";
          "Win-C-Shift-j" = "Win-C-Shift-j";
          "Win-C-Shift-k" = "Win-C-Shift-k";
          "C-d" = [ "delete" { set_mark = false; } ];
          "M-d" = [ "C-delete" { set_mark = false; } ];
          # Kill line
          "C-k" = [ "Shift-end" "C-x" { set_mark = false; } ];
          # Kill word backward
          "Alt-backspace" = [ "C-backspace" { set_mark = false; } ];
          # Set mark next word continuously
          "C-M-space" = [ "C-Shift-right" { set_mark = true; } ];
          # Undo
          "C-slash" = [ "C-z" { set_mark = false; } ];
          "C-Shift-ro" = "C-z";
          # Search
          "C-s" = "C-f";
          "M-Shift-5" = "C-h";
          # C-x prefix
          "C-x" = {
            remap = {
              h = [ "C-home" "C-a" { set_mark = true; } ];
              "C-f" = "C-o";
              "C-s" = "C-s";
              k = "C-f4";
              "C-c" = "C-q";
              u = [ "C-z" { set_mark = false; } ];
            };
          };
        };
      }
      {
        name = "F13 to Enter";
        remap = {
          "F13" = "Enter";
        };
      }
      {
        name = "F24 to Ctrl+V";
        remap = {
          "F24" = "C-v";
        };
      }
      {
        name = "Elecom Huge Plus";
        device.only = "HUGE PLUS HUGE PLUS";
        remap = {
          BTN_FORWARD = "Shift-Insert";  # Fn1 → ペースト
          BTN_BACK = "Win-o";            # Fn2 → Win-o
          BTN_TASK = "Enter";            # Fn3 → Enter
        };
      }
    ];
  };
}
