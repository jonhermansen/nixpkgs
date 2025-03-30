{
  lib,
  mkDerivation,
  libpam,
  libbsm,
}:
mkDerivation {
  path = "usr.bin/su";

  outputs = [
    "out"
    "man"
    "debug"
  ];

  buildInputs = [
    libpam
    libbsm
  ];

  meta.mainProgram = "su";
  meta.platforms = lib.platforms.freebsd;
}
