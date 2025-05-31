{
  lib,
  stdenv,
  mkKdeDerivation,
  qtdeclarative
}:
mkKdeDerivation {
  pname = "plasma-activities-stats";
  extraNativeBuildInputs = lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    qtdeclarative
  ];
}
