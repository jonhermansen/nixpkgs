{ lib
, mkXfceDerivation
, buildPackages
, polkit
, exo
, libxfce4util
, libxfce4ui
, libxfce4windowing
, xfconf
, iceauth
, gtk3
, gtk-layer-shell
, glib
, libwnck
, xfce4-session
}:

mkXfceDerivation {
  category = "xfce";
  pname = "xfce4-session";
  version = "4.20.2";

  sha256 = "sha256-wd+8W9Z0dH7bqILBUNG9YxpRf8TnRJ/7b3QviM1HVnY=";

  buildInputs = [
    exo
    gtk3
    gtk-layer-shell
    glib
    libxfce4ui
    libxfce4util
    libxfce4windowing
    libwnck
    xfconf
    polkit
    iceauth
  ];

  nativeBuildInputs = [
    glib
  ];

  # meson doesn't work yet and autoconf won't pick up the right two glibs unless we produce this monster
  preConfigure = ''
    mkdir -p $TMP/lib/pkgconfig
    cp -r ${glib.dev}/lib/pkgconfig/*.pc $TMP/lib/pkgconfig
    substituteInPlace $TMP/lib/pkgconfig/*.pc --replace-quiet ${glib.dev}/bin ${buildPackages.glib.dev}/bin
    export PKG_CONFIG_PATH="$TMP/lib/pkgconfig:$PKG_CONFIG_PATH"
  '';

  configureFlags = [
    "--with-xsession-prefix=${placeholder "out"}"
    "--with-wayland-session-prefix=${placeholder "out"}"
    "ICEAUTH=${lib.getExe iceauth}"
  ];

  passthru.xinitrc = "${xfce4-session}/etc/xdg/xfce4/xinitrc";

  meta = with lib; {
    description = "Session manager for Xfce";
    maintainers = with maintainers; [ ] ++ teams.xfce.members;
  };
}
