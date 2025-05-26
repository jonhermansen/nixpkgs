{
  lib,
  stdenv,
  qtModule,
  qtdeclarative,
  qtbase,
  qtwayland,
  wayland,
  wayland-scanner,
  libdrm,
  fetchpatch2,
}:

qtModule {
  pname = "qtwayland";
  # wayland-scanner needs to be propagated as both build
  # (for the wayland-scanner binary) and host (for the
  # actual wayland.xml protocol definition)
  propagatedBuildInputs = [
    qtdeclarative
    wayland
    wayland-scanner
  ];
  propagatedNativeBuildInputs = [
    wayland
    wayland-scanner
  ];
  buildInputs = [ libdrm ];
  nativeBuildInputs = [
    qtbase
  ] ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    qtwayland
  ];

  outputs = [ "out" "dev" ];

  patches = [
    # run waylandscanner with private-code to avoid conflict with symbols from libwayland
    # better solution for https://github.com/NixOS/nixpkgs/pull/337913
    (fetchpatch2 {
      url = "https://invent.kde.org/qt/qt/qtwayland/-/commit/67f121cc4c3865aa3a93cf563caa1d9da3c92695.patch";
      hash = "sha256-uh5lecHlHCWyO1/EU5kQ00VS7eti3PEvPA2HBCL9K0k=";
    })
    (fetchpatch2 {
      url = "https://raw.githubusercontent.com/freebsd/freebsd-ports/66259c9c641b1fc828becbe2959dbe7380e55fe1/graphics/qt6-wayland/files/patch-CMakeLists.txt";
      extraPrefix = "";
      hash = "sha256-CYmIf6MlvdMea2PDAqroPEGKh2rdNNRpojDVYbAm9Vs=";
    })
  ];

  meta = {
    platforms = lib.platforms.unix;
    badPlatforms = lib.platforms.darwin;
  };
}
