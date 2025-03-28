{
  lib,
  stdenv,
  qtModule,
  qtbase,
  qtdeclarative,
  openssl,
  qtquick3d,
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
}
