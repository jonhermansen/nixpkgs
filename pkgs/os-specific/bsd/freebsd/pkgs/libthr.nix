{
  lib,
  stdenv,
  fetchpatch,
  mkDerivation,
  libcMinimal,
  include,
  libgcc,
  csu,
  extraSrc ? [ ],
}:

mkDerivation {
  path = "lib/libthr";
  extraPaths = [
    "lib/libthread_db"
    "lib/libc" # needs /include + arch-specific files
    "libexec/rtld-elf"
  ]
  ++ extraSrc;

  outputs = [
    "out"
    "man"
    "debug"
  ];

  noLibc = true;

  buildInputs = [
    libcMinimal
    include
    libgcc
  ];

  patches = [
    # https://github.com/freebsd/freebsd-src/pull/1882
    (fetchpatch {
      name = "freebsd-libthr-use-notstring-attribute.patch";
      url = "https://github.com/freebsd/freebsd-src/pull/1882/commits/163378029962e2d1d62f8507ace8f7abfc0e3bce.diff";
      hash = "sha256-M/KmryB7x2ii8/GsSXF4jXnj8kK6v5yEofqdzBh4Xvk=";
      includes = ["lib/libthr/thread/thr_printf.c"];
    })
  ];

  # Presumably newer Clang has gotten more strict.
  CWARNEXTRA = "-Wno-cast-function-type-mismatch";

  preBuild = ''
    export NIX_CFLAGS_COMPILE="-Wno-error=unknown-attributes  $NIX_CFLAGS_COMPILE -B${csu}/lib"
  '';

  postInstall = lib.optionalString stdenv.hostPlatform.isStatic ''
    rm $out/lib/libpthread.so
  '';

  env.MK_TESTS = "no";
}
