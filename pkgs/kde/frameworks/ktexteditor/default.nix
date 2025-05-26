{
  lib,
  stdenv,
  mkKdeDerivation,
  qtdeclarative,
  qtspeech,
  editorconfig-core-c,
  kauth,
  symlinkJoin,
  kdoctools,
  kconfig,
}:
let
  hostTools = symlinkJoin {
    pname = "kdoctools-kconfig-kauth";
    inherit (kconfig) version;
    paths = [
      (kdoctools.__spliced.buildHost or kdoctools).dev
      (kconfig.__spliced.buildHost or kconfig).dev
      (kauth.__spliced.buildHost or kauth).dev
    ];
  };
in
mkKdeDerivation {
  pname = "ktexteditor";

  extraBuildInputs = [
    qtspeech
    editorconfig-core-c
  ];
  extraNativeBuildInputs = [
    qtdeclarative
  ];
  extraCmakeFlags = lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    "-DKF6_HOST_TOOLING=${hostTools}/lib/cmake"
  ];
}
