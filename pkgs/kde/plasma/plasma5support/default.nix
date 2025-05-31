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

  extraBuildInputs = [ gpsd ];
}
