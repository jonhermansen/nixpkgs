{ lib, mkXfceDerivation, exo, librsvg, glib, dbus-glib, libepoxy, gtk3, libXdamage
, libstartup_notification, libxfce4ui, libxfce4util, libwnck, buildPackages
, libXpresent, xfconf, libXinerama, gdk-pixbuf }:

mkXfceDerivation {
  category = "xfce";
  pname = "xfwm4";
  version = "4.20.0";

  sha256 = "sha256-5UZQrAH0oz+G+7cvXCLDJ4GSXNJcyl4Ap9umb7h0f5Q=";

  nativeBuildInputs = [ exo ];

  buildInputs = [
    dbus-glib
    libepoxy
    gtk3
    libXdamage
    libstartup_notification
    libxfce4ui
    libxfce4util
    libwnck
    libXpresent
    xfconf
    libXinerama
  ];

  # meson doesn't work yet and autoconf won't pick up the right two glibs unless we produce this monster
  preConfigure = ''
    mkdir -p $TMP/lib/pkgconfig
    cp -r ${glib.dev}/lib/pkgconfig/*.pc $TMP/lib/pkgconfig
    substituteInPlace $TMP/lib/pkgconfig/*.pc --replace-quiet ${glib.dev}/bin ${buildPackages.glib.dev}/bin
    export PKG_CONFIG_PATH="$TMP/lib/pkgconfig:$PKG_CONFIG_PATH"
  ''
  # there is no gdk-pixbuf wrapper and one of the buildInputs propagated to us is gdk-pixbuf
  # so the setup hooks clobber each other. However we need the other one for installation.
  + ''
    export GDK_PIXBUF_MODULE_FILE="${buildPackages.librsvg.out}/${gdk-pixbuf.binaryDir}/loaders.cache"
  '';

  postBuild = ''
    export GDK_PIXBUF_MODULE_FILE="${librsvg.out}/${gdk-pixbuf.binaryDir}/loaders.cache"
  '';

  meta = with lib; {
    description = "Window manager for Xfce";
    maintainers = with maintainers; [ ] ++ teams.xfce.members;
  };
}
