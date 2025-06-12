{
  lib,
  stdenv,
  mkKdeDerivation,
  qtsvg,
  qtwayland,
  qtdeclarative,
  wayland,
  pkg-config,
  kdeHostTools,
}:
mkKdeDerivation {
  pname = "libplasma";

  extraNativeBuildInputs = [
    pkg-config
    qtdeclarative
    qtwayland
    kdeHostTools
  ];
  extraBuildInputs = [
    qtsvg
    qtwayland
    wayland
  ];
}
