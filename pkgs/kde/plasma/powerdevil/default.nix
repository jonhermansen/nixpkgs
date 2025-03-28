{
  lib,
  stdenv,
  mkKdeDerivation,
  pkg-config,
  ddcutil,
  qtwayland,
  kdeHostTools,
  kconfig,
}:
mkKdeDerivation {
  pname = "powerdevil";

  extraNativeBuildInputs = [
    pkg-config
    kdeHostTools
    kconfig
    qtwayland
  ];
  extraBuildInputs = [
    qtwayland
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    ddcutil
  ];
}
