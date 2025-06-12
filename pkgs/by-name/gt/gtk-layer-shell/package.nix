{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  meson,
  ninja,
  pkg-config,
  gtk-doc,
  docbook-xsl-nons,
  docbook_xml_dtd_43,
  wayland-scanner,
  wayland,
  gtk3,
  gobject-introspection,
  vala,
  withIntrospection ? lib.meta.availableOn stdenv.hostPlatform gobject-introspection && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtk-layer-shell";
  version = "0.9.1";

  outputs = [
    "out"
    "dev"
    "devdoc"
  ];
  outputBin = "devdoc"; # for demo

  src = fetchFromGitHub {
    owner = "wmww";
    repo = "gtk-layer-shell";
    rev = "v${finalAttrs.version}";
    hash = "sha256-TObAo/YgS6ObYrNLitxMwneGzLxwnnBIOhBVAeAzbt4=";
  };

  strictDeps = true;

  depsBuildBuild = [
    pkg-config
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gtk-doc
    docbook-xsl-nons
    docbook_xml_dtd_43
    wayland-scanner
    wayland-scanner
  ]
  ++ lib.optionals withIntrospection [
    vala
    gobject-introspection
  ];

  buildInputs = [
    wayland
    gtk3
  ];

  mesonFlags = [
    "-Ddocs=true"
    # configure error: Vala bindings require introspection support
    (lib.mesonBool "examples" withIntrospection)
    (lib.mesonBool "introspection" withIntrospection)
  ];

  meta = with lib; {
    description = "Library to create panels and other desktop components for Wayland using the Layer Shell protocol";
    mainProgram = "gtk-layer-demo";
    homepage = "https://github.com/wmww/gtk-layer-shell";
    license = licenses.lgpl3Plus;
    maintainers = with maintainers; [
      eonpatapon
      donovanglover
    ];
    platforms = platforms.linux ++ platforms.freebsd;
  };
})
