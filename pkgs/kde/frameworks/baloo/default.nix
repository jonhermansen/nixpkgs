{
  lib,
  stdenv,
  mkKdeDerivation,
  qtdeclarative,
  lmdb,
  kconfig,
}:
mkKdeDerivation {
  pname = "baloo";

  # kde-systemd-start-condition is not part of baloo
  postPatch = ''
    substituteInPlace src/file/kde-baloo.service.in --replace-fail @KDE_INSTALL_FULL_BINDIR@/kde-systemd-start-condition /run/current-system/sw/bin/kde-systemd-start-condition
  '';

  extraBuildInputs = [
    qtdeclarative
    lmdb
  ];
  extraNativeBuildInputs = [
    qtdeclarative
    kconfig
  ];
  extraCmakeFlags = lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    "-DKF6_HOST_TOOLING=${(kconfig.__spliced.buildHost or kconfig).dev}/lib/cmake"
  ];
}
