{
  lib,
  stdenv,
  evdev-proto,
  mkKdeDerivation,
  pkg-config,
  qtwayland,
}:
mkKdeDerivation {
  pname = "kwayland";

  extraNativeBuildInputs = [ pkg-config qtwayland ];
  extraBuildInputs = [ qtwayland ] ++ lib.optionals stdenv.hostPlatform.isFreeBSD [ evdev-proto ];
}
