{ lib
, stdenv
, replaceVars
, fetchFromGitHub
, buildPackages
, meson
, mesonEmulatorHook
, appstream
, ninja
, pkg-config
, cmake
, gettext
, xmlto
, docbook-xsl-nons
, docbook_xml_dtd_45
, libxslt
, libstemmer
, glib
, xapian
, libxml2
, libxmlb
, libyaml
, gobject-introspection
, pcre
, itstool
, gperf
, vala
, curl
, cairo
, gdk-pixbuf
, pango
, librsvg
, systemd
, nixosTests
, testers
, withSystemd ? lib.meta.availableOn stdenv.hostPlatform systemd
, withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "appstream";
  version = "1.0.4";

  outputs = [ "out" "dev" "installedTests" ];

  src = fetchFromGitHub {
    owner = "ximion";
    repo = "appstream";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-UnSJcXH0yWK/dPKgbOx9x3iJjKcKNYFkD2Qs5c3FtM8=";
  };

  patches = [
    # Fix hardcoded paths
    (replaceVars ./fix-paths.patch {
      libstemmer_includedir = "${lib.getDev libstemmer}/include";
    })

    # Allow installing installed tests to a separate output.
    ./installed-tests-path.patch
  ];

  postPatch = lib.optionalString (!stdenv.buildPlatform.canExecute stdenv.hostPlatform && !stdenv.hostPlatform.emulatorAvailable buildPackages) ''
    sed -E -i -e '/override_find_program/d' tools/meson.build
  '';

  strictDeps = true;

  depsBuildBuild = [
    pkg-config
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    cmake
    gettext
    libxslt
    xmlto
    docbook-xsl-nons
    docbook_xml_dtd_45
    itstool
    gperf
    glib
  ] ++ lib.optionals withIntrospection [
    gobject-introspection
    vala
  ] ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) ([
    appstream
  ] ++ lib.optionals withIntrospection [
    mesonEmulatorHook
  ]);

  buildInputs = [
    libstemmer
    pcre
    glib
    xapian
    libxml2
    libxmlb
    libyaml
    curl
    cairo
    gdk-pixbuf
    pango
    librsvg
  ] ++ lib.optionals withSystemd [
    systemd
  ];

  mesonFlags = [
    "-Dapidocs=false"
    "-Ddocs=false"
    "-Dvapi=true"
    "-Dinstalled_test_prefix=${placeholder "installedTests"}"
    "-Dcompose=true"
    (lib.mesonBool "gir" withIntrospection)
  ] ++ lib.optionals (!withSystemd) [
    "-Dsystemd=false"
  ];

  passthru.tests = {
    installed-tests = nixosTests.installed-tests.appstream;
    pkg-config = testers.hasPkgConfigModules {
      package = finalAttrs.finalPackage;
    };
  };

  meta = with lib; {
    description = "Software metadata handling library";
    longDescription = ''
      AppStream is a cross-distro effort for building Software-Center applications
      and enhancing metadata provided by software components.  It provides
      specifications for meta-information which is shipped by upstream projects and
      can be consumed by other software.
    '';
    homepage = "https://www.freedesktop.org/wiki/Distributions/AppStream/";
    license = licenses.lgpl21Plus;
    mainProgram = "appstreamcli";
    platforms = platforms.unix;
    pkgConfigModules = [ "appstream" ];
  };
})
