{
  lib,
  stdenv,
  mkKdeDerivation,
  pkg-config,
  gpsd,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "plasma5support";

  extraNativeBuildInputs = [
    pkg-config
    qtdeclarative
  ];

  excludeDependencies = lib.optionals stdenv.hostPlatform.isFreeBSD [
    "networkmanager-qt"
  ];

  extraBuildInputs = [ gpsd ];
}
