{
  lib,
  stdenv,
  mkKdeDerivation,
  pkg-config,
  qtwayland,
  cups,
  qtdeclarative,
  evdev-proto,
}:
mkKdeDerivation {
  pname = "xdg-desktop-portal-kde";

  extraNativeBuildInputs = [
    pkg-config
    qtdeclarative
    qtwayland
  ];
  extraBuildInputs = [
    qtwayland
    cups
  ] ++ lib.optionals stdenv.hostPlatform.isFreeBSD [
    evdev-proto
  ];
}
