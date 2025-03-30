{
  lib,
  mkDerivation,
  libpam,
}:
mkDerivation {
  path = "usr.bin/passwd";

  buildInputs = [
    libpam
  ];

  outputs = [
    "out"
    "man"
    "debug"
  ];

  meta.platforms = lib.platforms.freebsd;
  meta.mainProgram = "passwd";
}
