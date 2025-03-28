{
  lib,
  mkDerivation,
  libutil,
  flex,
  byacc,
}:
mkDerivation {
  path = "sbin/devd";

  outputs = [
    "out"
    "etc"
    "man"
    "debug"
  ];

  buildInputs = [
    libutil
  ];

  extraNativeBuildInputs = [
    flex
    byacc
  ];

  clangFixup = false;

  MK_TESTS = "no";
  MK_AUTOFS = "yes";
  MK_BLUETOOTH = "yes";
  MK_HYPERV = "yes";
  MK_USB = "yes";
  MK_ZFS = "yes";

  postInstall = ''
    make $makeFlags installconfig
  '';

  meta.platforms = lib.platforms.freebsd;
  meta.mainProgram = "devd";
}
