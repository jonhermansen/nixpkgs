{
  lib,
  stdenv,
  mkKdeDerivation,
  python3,
  libxml2,
  qtsvg,
  breeze-icons,
  cmake,
}:
mkKdeDerivation {
  pname = "breeze-icons";

  extraNativeBuildInputs = [
    (python3.withPackages (ps: [ ps.lxml ]))
    libxml2
  ];

  # This package contains an SVG icon theme and an API forcing its use
  extraPropagatedBuildInputs = [
    qtsvg
  ];

  nativeBuildInputs = [
    cmake
  ] ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    breeze-icons.devtools
  ];

  postInstall = ''
    mkdir -p $devtools/bin
    cp bin/{qrcAlias,generate-symbolic-dark} $devtools/bin
  '';

  # lots of icons, takes forever, does absolutely nothing
  dontStrip = true;
  dontWrapQtApps = true;
}
