{
  lib,
  stdenv,
  fetchFromGitLab,
  gitUpdater,
  buildPackages,
  meson,
  mesonEmulatorHook,
  ninja,
  glib,
  check,
  python3,
  vala,
  gtk-doc,
  glibcLocales,
  libxml2,
  libxslt,
  pkg-config,
  sqlite,
  docbook_xsl,
  docbook_xml_dtd_43,
  gobject-introspection,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
  withGtkDoc ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

stdenv.mkDerivation rec {
  pname = "libaccounts-glib";
  version = "1.27";

  outputs = [
    "out"
    "dev"
  ]
  ++ lib.optional withGtkDoc "devdoc"
  ++ lib.optional withIntrospection "py"
  ;

  src = fetchFromGitLab {
    owner = "accounts-sso";
    repo = "libaccounts-glib";
    rev = "VERSION_${version}";
    hash = "sha256-mLhcwp8rhCGSB1K6rTWT0tuiINzgwULwXINfCbgPKEg=";
  };

  nativeBuildInputs =
    [
      check
      docbook_xml_dtd_43
      docbook_xsl
      glibcLocales
      meson
      ninja
      pkg-config
      vala
      glib
    ]
    ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform && stdenv.hostPlatform.emulatorAvailable buildPackages) [
      mesonEmulatorHook
    ]
    ++ lib.optionals withIntrospection [
      gobject-introspection
    ]
    ++ lib.optionals withGtkDoc [
      gtk-doc
    ]
    ;

  buildInputs = [
    glib
    libxml2
    libxslt
    sqlite
  ]
  ++ lib.optionals withIntrospection [
    python3.pkgs.pygobject3
  ]
  ;

  patches = [
    ./vala-option.patch
  ];

  LC_ALL = "en_US.UTF-8";

  mesonFlags = [
    (lib.mesonBool "introspection" withIntrospection)
    (lib.mesonBool "docs" withGtkDoc)
    (lib.mesonBool "tests" false)
  ]
  ++ lib.optionals withIntrospection [
    "-Dinstall-py-overrides=true"
    "-Dpy-overrides-dir=${placeholder "py"}/${python3.sitePackages}/gi/overrides"
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "VERSION_";
  };

  meta = with lib; {
    description = "Library for managing accounts which can be used from GLib applications";
    homepage = "https://gitlab.com/accounts-sso/libaccounts-glib";
    platforms = platforms.linux ++ platforms.freebsd;
    license = licenses.lgpl21;
  };
}
