{
  lib,
  stdenv,
  mkKdeDerivation,
  qtwebchannel,
  qtwebengine,
  qtdeclarative,
  qttools,
  libpcap,
  libnl,
  lm_sensors,
  kdoctools,
  kconfig,
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
  pname = "libksysguard";

  extraBuildInputs = [
    qtwebchannel
    qttools
    libpcap
  ]

  ++ lib.optional (lib.meta.availableOn stdenv.hostPlatform lm_sensors) lm_sensors
  ++ lib.optional (lib.meta.availableOn stdenv.hostPlatform libnl) libnl
  ++ lib.optional (lib.meta.availableOn stdenv.hostPlatform qtwebengine) qtwebengine
  ;

  extraNativeBuildInputs = [
    qtdeclarative
  ];
  extraCmakeFlags = lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    "-DKF6_HOST_TOOLING=${hostTools}/lib/cmake"
  ];
}
