{
  lib,
  stdenv,
  qtModule,
  qtbase,
  qtdeclarative,
  openssl,
  qtquick3d,
  qtshadertools,
}:

qtModule {
  pname = "qtquick3d";
  propagatedBuildInputs = [
    qtbase
    qtdeclarative
  ];
  buildInputs = [
    openssl
  ];
  nativeBuildInputs = [
    qtdeclarative
  ] ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    qtquick3d
  ];
  cmakeFlags = lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    "-DQt6ShaderToolsTools_DIR=${qtshadertools.__spliced.buildHost}/lib/cmake/Qt6ShaderToolsTools"
  ];
}
