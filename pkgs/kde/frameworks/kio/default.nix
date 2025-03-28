{
  stdenv,
  lib,
  mkKdeDerivation,
  qt5compat,
  qtdeclarative,
  qttools,
  acl,
  attr,
  symlinkJoin,
  kconfig,
  kauth,
  kdoctools,
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
  pname = "kio";

  patches = [
    # Remove hardcoded smbd search path
    ./0001-Remove-impure-smbd-search-path.patch
  ];

  extraNativeBuildInputs = [
    qtdeclarative
  ];

  extraBuildInputs = [
    qt5compat
    qttools
  ]
  ++ lib.optional (lib.meta.availableOn stdenv.hostPlatform acl) acl
  ++ lib.optional (lib.meta.availableOn stdenv.hostPlatform attr) attr
  ;

  extraCmakeFlags = lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    "-DKF6_HOST_TOOLING=${hostTools}/lib/cmake"
  ];
}
