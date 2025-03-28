{
  lib,
  stdenv,
  mkKdeDerivation,
  qtsvg,
  qtwayland,
  qtdeclarative,
  wayland,
  pkg-config,
  kconfig,
  kdoctools,
  kauth,
  kcmutils,
  kpackage,
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
      (kpackage.__spliced.buildHost or kpackage).dev
    ];
  };
in
mkKdeDerivation {
  pname = "libplasma";

  extraNativeBuildInputs = [
    pkg-config
    qtdeclarative
    qtwayland
  ];
  extraBuildInputs = [
    qtsvg
    qtwayland
    wayland
  ];
  extraCmakeFlags = lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    "-DKF6_HOST_TOOLING=${hostTools}/lib/cmake"
  ];
}
