{
  lib,
  stdenv,
  mkKdeDerivation,
  pkg-config,
  kidletime,
  networkmanager-qt,
  plasma-activities,
  gpsd,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "plasma5support";

  extraNativeBuildInputs = [
    pkg-config
    qtdeclarative
  ];

  extraBuildInputs = [
    kidletime
    plasma-activities
    gpsd
  ] ++ lib.optionals (!stdenv.hostPlatform.isFreeBSD) [
    networkmanager-qt
  ];
}
