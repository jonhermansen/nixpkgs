{
  lib,
  stdenv,
  mkKdeDerivation,
  intltool,
  qtdeclarative,
  kconfig,
  kdoctools,
  kauth,
  kcmutils,
  symlinkJoin,
}:
let
  hostTools = symlinkJoin {
    pname = "kdoctools-kconfig-kauth";
    inherit (kconfig) version;
    paths = [
      (kdoctools.__spliced.buildHost or kdoctools).dev
      (kconfig.__spliced.buildHost or kconfig).dev
      (kauth.__spliced.buildHost or kauth).dev
      (kcmutils.__spliced.buildHost or kcmutils).dev
    ];
  };
in
mkKdeDerivation {
  pname = "kaccounts-integration";

  propagatedNativeBuildInputs = [ intltool ];
  extraNativeBuildInputs = [
    qtdeclarative
  ];
  extraCmakeFlags = lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    "-DKF6_HOST_TOOLING=${hostTools}/lib/cmake"
  ];
}
