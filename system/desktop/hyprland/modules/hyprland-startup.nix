{ pkgs, config }:
let
  cfg = config.icedos;
  browser =
    if (cfg.applications.librewolf.enable && cfg.applications.librewolf.default) then
      "run librewolf"
    else if (cfg.applications.zen-browser.enable && cfg.applications.zen-browser.default) then
      "run zen"
    else
      "";

  monitor = cfg.hardware.monitors.a.name;

  pwas =
    if
      (
        cfg.applications.librewolf.enable
        && cfg.applications.librewolf.default
        && cfg.applications.librewolf.pwas.enable
      )
    then
      "run librewolf-pwas"
    else if
      (
        cfg.applications.zen-browser.enable
        && cfg.applications.zen-browser.default
        && cfg.applications.zen-browser.pwas.enable
      )
    then
      "run zen-pwas"
    else
      "";
in
pkgs.writeShellScriptBin "hyprland-startup" ''
  run () {
    pidof $1 || $1 $2 &
  }

  # Basic functionalities
  run "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
  run valent
  cliphist wipe
  run hyprland-per-window-layout
  run hyprpaper
  run swaync
  run swayosd
  wl-paste --type image --watch cliphist store &
  wl-paste --type text --watch cliphist store &
  xrandr --output "${monitor}" --primary
  run poweralertd
  sleep 1 && hyprctl reload
  sleep 1 && run waybar

  # Tray applications
  nm-applet --indicator &

  # Standard applications
  ${browser}
  ${pwas}
  nautilus -w &
  nautilus -w &
  run steam
  run blueberry
  run pavucontrol
  run signal-desktop

  # Terminals/Task managers/IDEs
  kitty --class task-managers btop &
  kitty --class terminals tmux new -s terminals \; split-window -v \; select-pane -U \; split-window -h \; select-pane -D &
  kitty --class nvchad tmux new -s nvchad nvim &

  # Idle manager
  run hypridle
''
