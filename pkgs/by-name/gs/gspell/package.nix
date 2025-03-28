{
  stdenv,
  lib,
  fetchurl,
  buildPackages,
  docbook-xsl-nons,
  glib,
  gobject-introspection,
  gtk-doc,
  meson,
  ninja,
  pkg-config,
  vala,
  mesonEmulatorHook,
  gtk3,
  icu,
  enchant2,
  gnome,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
  withGtkDoc ? (stdenv.buildPlatform.canExecute stdenv.hostPlatform) || (stdenv.hostPlatform.emulatorAvailable buildPackages),
}:

stdenv.mkDerivation rec {
  pname = "gspell";
  version = "1.14.0";

  outputs = [
    "out"
    "dev"
  ] ++ lib.optionals withGtkDoc [
    "devdoc"
  ];

  outputBin = "dev";

  src = fetchurl {
    url = "mirror://gnome/sources/${pname}/${lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "ZOodjp7cHCW0WpIOgNr2dVnRhm/81/hDL+z+ptD+iJc=";
  };

  nativeBuildInputs =
    [
      docbook-xsl-nons
      glib # glib-mkenums
      meson
      ninja
      pkg-config
    ] ++ lib.optionals withGtkDoc [
      gtk-doc
    ] ++ lib.optionals withIntrospection [
      gobject-introspection
      vala
    ]
    ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform && stdenv.hostPlatform.emulatorAvailable buildPackages) [
      mesonEmulatorHook
    ];

  buildInputs = [
    gtk3
    icu
  ];

  propagatedBuildInputs = [
    # required for pkg-config
    enchant2
  ];

  mesonFlags = [
    (lib.mesonBool "gobject_introspection" withIntrospection)
    (lib.mesonBool "vapi" withIntrospection)
    (lib.mesonBool "gtk_doc" withGtkDoc)
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
      versionPolicy = "none";
    };
  };

  meta = with lib; {
    description = "Spell-checking library for GTK applications";
    mainProgram = "gspell-app1";
    homepage = "https://gitlab.gnome.org/GNOME/gspell";
    license = licenses.lgpl21Plus;
    maintainers = teams.gnome.members;
    platforms = platforms.unix;
  };
}
