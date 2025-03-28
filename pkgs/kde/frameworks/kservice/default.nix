{
  lib,
  stdenv,
  qtdeclarative,
  mkKdeDerivation,
  kconfig,
  kdoctools,
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
  pname = "kservice";

  # FIXME(later): upstream
  patches = [
    # follow symlinks when generating sycoca
    ./qdiriterator-follow-symlinks.patch
    # explode less when sycoca is deleted
    ./handle-sycoca-deletion.patch
  ];
  extraNativeBuildInputs = [
    qtdeclarative
  ] ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    #kservice
  ];
  extraCmakeFlags = lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    "-DKF6_HOST_TOOLING=${hostTools}/lib/cmake"
  ];
  meta.mainProgram = "kbuildsycoca6";
}
