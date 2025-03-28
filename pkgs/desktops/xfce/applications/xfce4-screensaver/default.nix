{
  stdenv,
  mkXfceDerivation,
  buildPackages,
  gobject-introspection,
  dbus-glib,
  garcon,
  glib,
  gtk3,
  libX11,
  libXScrnSaver,
  libXrandr,
  libwnck,
  libxfce4ui,
  libxfce4util,
  libxklavier,
  pam,
  python3,
  systemd,
  xfconf,
  xfdesktop,
  lib,
  enableSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

let
  # For xfce4-screensaver-configure
  pythonEnv = python3.withPackages (pp: [ pp.pygobject3 ]);
in
mkXfceDerivation {
  category = "apps";
  pname = "xfce4-screensaver";
  version = "4.18.4";

  sha256 = "sha256-vkxkryi7JQg1L/JdWnO9qmW6Zx6xP5Urq4kXMe7Iiyc=";

  nativeBuildInputs = lib.optionals withIntrospection [
    gobject-introspection
  ];

  buildInputs = [
    dbus-glib
    garcon
    glib
    gtk3
    libX11
    libXScrnSaver
    libXrandr
    libwnck
    libxfce4ui
    libxfce4util
    libxklavier
    pam
    xfconf
  ] ++ lib.optionals enableSystemd [
    systemd
  ] ++ lib.optionals withIntrospection [
    pythonEnv
  ];

  configureFlags = [ "--without-console-kit" ];

  makeFlags = [ "DBUS_SESSION_SERVICE_DIR=$(out)/etc" ];

  preFixup = ''
    # For default wallpaper.
    gappsWrapperArgs+=(--prefix XDG_DATA_DIRS : "${xfdesktop}/share")
  '';

  meta = with lib; {
    description = "Screensaver for Xfce";
    maintainers = with maintainers; [ symphorien ] ++ teams.xfce.members;
  };
}
