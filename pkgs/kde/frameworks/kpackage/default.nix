{
  lib,
  stdenv,
  mkKdeDerivation,
  kdoctools,
  libxml2,
}:
mkKdeDerivation {
  pname = "kpackage";

  # Follow symlinks when resolving packages
  # FIXME(later): upstream
  patches = [ ./follow-symlinks.patch ];
  extraCmakeFlags = lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    "-DKF6_HOST_TOOLING=${(kdoctools.__spliced.buildHost or kdoctools).dev}/lib/cmake"
  ];
  extraNativeBuildInputs = [
    libxml2
  ];
  meta.mainProgram = "kpackagetool6";
}
