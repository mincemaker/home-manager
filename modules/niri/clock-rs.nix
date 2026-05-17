_:

{
  programs.clock-rs = {
    enable = true;
    settings = {
      general = {
        color = "magenta";
        interval = 250;
        blink = true;
        bold = true;
      };
      position = {
        horizontal = "center";
        vertical = "center";
      };
      date = {
        fmt = "%Y-%m-%d (%a)";
        use_12h = false;
        utc = false;
        hide_seconds = false;
      };
    };
  };
}
