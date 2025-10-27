{
  mkDerivation,
  fetchpatch,
  include,
  rpcgen,
  flex,
  byacc,
  csu,
  extraSrc ? [ ],
}:

mkDerivation {
  path = "libexec/rtld-elf";
  extraPaths = [
    "lib/csu"
    "lib/libc"
    "lib/libmd"
    "lib/msun"
    "lib/libutil"
    "lib/libc_nonshared"
    "include/rpcsvc"
    "contrib/libc-pwcache"
    "contrib/libc-vis"
    "contrib/tzcode"
    "contrib/gdtoa"
    "contrib/jemalloc"
    "sys/sys"
    "sys/kern"
    "sys/libkern"
    "sys/crypto"
  ]
  ++ extraSrc;

  patches = [
    # https://github.com/freebsd/freebsd-src/pull/1882
    (fetchpatch {
      name = "freebsd-rtld-use-notstring-attribute.patch";
      url = "https://github.com/freebsd/freebsd-src/pull/1882/commits/163378029962e2d1d62f8507ace8f7abfc0e3bce.diff";
      hash = "sha256-iaNWiSesh8JsvhTph1EggBNpwIxnT58B48CB1AgM7Cw=";
      includes = ["libexec/rtld-elf/rtld.c"];
    })
  ];

  outputs = [
    "out"
    "man"
    "debug"
  ];

  noLibc = true;

  buildInputs = [
    include
  ];

  extraNativeBuildInputs = [
    rpcgen
    flex
    byacc
  ];

  preBuild = ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -B${csu}/lib"
    make -C $BSDSRCDIR/lib/libc $makeFlags libc_nossp_pic.a
  '';

  # definitely a bad idea to enable stack protection on the stack protection initializers
  hardeningDisable = [ "stackprotector" ];

  env.MK_TESTS = "no";
}
