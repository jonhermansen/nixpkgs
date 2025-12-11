{
  lib,
  mkDerivation,
}:
mkDerivation {
  path = "lib/libdevdctl";
  clangFixup = false;

  outputs = [
    "out"
    "debug"
  ];

  NIX_CFLAGS_COMPILE = [
    "-Wno-c++20-extensions"
    "-Wno-nullability-completeness"
  ];

  meta.platforms = lib.platforms.freebsd;
}
