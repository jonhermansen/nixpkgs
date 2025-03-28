{
  lib,
  stdenv,
  mkKdeDerivation,
  buildPackages,
}:
mkKdeDerivation {
  pname = "kpty";
  extraCmakeFlags = lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    "-DUTEMPTER_EXECUTABLE=${buildPackages.libutempter}/lib/utempter/utempter"
  ];
}
