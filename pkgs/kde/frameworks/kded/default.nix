{
  lib,
  stdenv,
  mkKdeDerivation,
  qtdeclarative,
  kdoctools,
  kconfig,
  symlinkJoin,
}:
let
  hostTools = symlinkJoin {
    pname = "kdoctools-kconfig";
    inherit (kconfig) version;
    paths = [
      (kdoctools.__spliced.buildHost or kdoctools).dev
      (kconfig.__spliced.buildHost or kconfig).dev
    ];
  };
in
mkKdeDerivation {
  pname = "kded";

  extraNativeBuildInputs = [
    qtdeclarative
  ];

  extraCmakeFlags = lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    "-DKF6_HOST_TOOLING=${hostTools}/lib/cmake"
  ];

  meta.mainProgram = "kded6";
}
