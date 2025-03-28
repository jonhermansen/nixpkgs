{
  lib,
  stdenv,
  mkKdeDerivation,
  python3,
  libxml2,
  breeze-icons,
  cmake,
}:
mkKdeDerivation {
  pname = "breeze-icons";

  extraNativeBuildInputs = [
    (python3.withPackages (ps: [ ps.lxml ]))
    libxml2
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
  dontStpip = true;
  dontWrapQtApps = true;
}
