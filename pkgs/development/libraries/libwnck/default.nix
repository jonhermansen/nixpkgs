{
  stdenv,
  lib,
  fetchurl,
  meson,
  mesonEmulatorHook,
  buildPackages,
  ninja,
  pkg-config,
  gtk-doc,
  docbook_xsl,
  docbook_xml_dtd_412,
  libX11,
  glib,
  gtk3,
  pango,
  cairo,
  libXres,
  libXi,
  libstartup_notification,
  gettext,
  gobject-introspection,
  gnome,
  withIntrospection ? (stdenv.buildPlatform.canExecute stdenv.hostPlatform) || (stdenv.hostPlatform.emulatorAvailable buildPackages),
  withGtkDoc ? (stdenv.buildPlatform.canExecute stdenv.hostPlatform) || (stdenv.hostPlatform.emulatorAvailable buildPackages),
}:


stdenv.mkDerivation rec {
  pname = "libwnck";
  version = "43.2";

  outputs = [
    "out"
    "dev"
  ] ++ lib.optionals withGtkDoc [
    "devdoc"
  ];
  outputBin = "dev";

  src = fetchurl {
    url = "mirror://gnome/sources/libwnck/${lib.versions.major version}/libwnck-${version}.tar.xz";
    sha256 = "VadETsH7uVwIbUCWc4jyMbXAu8jP+qCGv5KQrkSeUdU=";
  };

  nativeBuildInputs =
    [
      meson
      ninja
      pkg-config
      gettext
      docbook_xsl
      docbook_xml_dtd_412
      glib
    ]
    ++ lib.optionals withIntrospection [
      gobject-introspection
    ]
    ++ lib.optionals withGtkDoc [
      gtk-doc
    ]
    ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform && stdenv.hostPlatform.emulatorAvailable buildPackages) [
      mesonEmulatorHook
    ];

  buildInputs = [
    libX11
    libstartup_notification
    pango
    cairo
    libXres
    libXi
  ];

  propagatedBuildInputs = [
    glib
    gtk3
  ];

  mesonFlags = [
    "-Dgtk_doc=true"
    (lib.mesonEnable "introspection" withIntrospection)
    (lib.mesonBool "gtk_doc" withGtkDoc)
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "libwnck";
    };
  };

  meta = with lib; {
    description = "Library to manage X windows and workspaces (via pagers, tasklists, etc.)";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux ++ platforms.freebsd;
    maintainers = with maintainers; [ liff ];
  };
}
