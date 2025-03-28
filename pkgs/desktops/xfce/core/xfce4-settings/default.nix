{ lib
, stdenv
, mkXfceDerivation
, wayland-scanner
, exo
, garcon
, gtk3
, gtk-layer-shell
, glib
, libnotify
, libX11
, libXext
, libxfce4ui
, libxfce4util
, libxklavier
, upower
# Disabled by default on upstream and actually causes issues:
# https://gitlab.xfce.org/xfce/xfce4-settings/-/issues/222
, withUpower ? false
, wlr-protocols
, xfconf
, xf86inputlibinput
, libxml2
, colord
, withColord ? stdenv.buildPlatform.canExecute stdenv.hostPlatform
}:

mkXfceDerivation {
  category = "xfce";
  pname = "xfce4-settings";
  version = "4.20.1";

  sha256 = "sha256-9BFO1cN0etDHJzkGHl5GKL2qzJTlpaP/qfvfz6KWaMI=";

  nativeBuildInputs = [
    wayland-scanner
    libxml2
  ];

  buildInputs = [
    exo
    garcon
    glib
    gtk3
    gtk-layer-shell
    libnotify
    libX11
    libXext
    libxfce4ui
    libxfce4util
    libxklavier
    wlr-protocols
    xf86inputlibinput
    xfconf
  ]
  ++ lib.optionals withUpower [ upower ]
  ++ lib.optionals withColord [ colord ];

  configureFlags = [
    "--enable-pluggable-dialogs"
    "--enable-sound-settings"
  ]
  ++ lib.optionals withUpower [ "--enable-upower-glib" ]
  ++ lib.optionals withColord [ "--enable-colord" ];

  meta = with lib; {
    description = "Settings manager for Xfce";
    maintainers = with maintainers; [ ] ++ teams.xfce.members;
  };
}
