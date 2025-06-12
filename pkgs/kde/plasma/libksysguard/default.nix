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
  kdeHostTools,
}:
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
    kdeHostTools
  ];
}
