{
  stdenv,
  lib,
  fetchurl,
  meson,
  ninja,
  pkg-config,
  gobject-introspection,
  vala,
  buildPackages,
  enableManpages ? buildPackages.pandoc.compiler.bootstrapAvailable,
  gi-docgen,
  python3,
  libsoup_3,
  glib,
  gnome,
  gssdp-tools,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gssdp";
  version = "1.6.3";

  outputs = [
    "out"
    "dev"
  ]
  ++ lib.optionals withIntrospection [
    "devdoc"
  ];

  src = fetchurl {
    url = "mirror://gnome/sources/gssdp/${lib.versions.majorMinor finalAttrs.version}/gssdp-${finalAttrs.version}.tar.xz";
    sha256 = "L+21r9sizxTVSYo5p3PKiXiKJQ/PcBGHg9+CHh8/NEY=";
  };

  depsBuildBuild = [
    pkg-config
  ];

  nativeBuildInputs = [
    glib
    meson
    ninja
    pkg-config
    vala
    gi-docgen
    python3
  ]
  ++ lib.optionals withIntrospection [
    gobject-introspection
  ]
  ++ lib.optionals enableManpages [
    buildPackages.pandoc
  ];

  buildInputs = [
    libsoup_3
  ];

  propagatedBuildInputs = [
    glib
  ];

  mesonFlags = [
    (lib.mesonBool "gtk_doc" withIntrospection)
    "-Dsniffer=false"
    (lib.mesonBool "manpages" enableManpages)
    (lib.mesonBool "introspection" withIntrospection)
  ];

  # On Darwin: Failed to bind socket, Operation not permitted
  doCheck = !stdenv.hostPlatform.isDarwin;

  postFixup = lib.optionalString withIntrospection ''
    # Move developer documentation to devdoc output.
    # Cannot be in postInstall, otherwise _multioutDocs hook in preFixup will move right back.
    find -L "$out/share/doc" -type f -regex '.*\.devhelp2?' -print0 \
      | while IFS= read -r -d ''' file; do
        moveToOutput "$(dirname "''${file/"$out/"/}")" "$devdoc"
    done
  '';

  passthru = {
    updateScript = gnome.updateScript {
      attrPath = "gssdp_1_6";
      packageName = "gssdp";
    };

    tests = {
      inherit gssdp-tools;
    };
  };

  meta = with lib; {
    description = "GObject-based API for handling resource discovery and announcement over SSDP";
    homepage = "http://www.gupnp.org/";
    license = licenses.lgpl2Plus;
    teams = [ teams.gnome ];
    platforms = platforms.all;
  };
})
