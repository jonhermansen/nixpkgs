{ lib, stdenv, fetchurl, fetchpatch, pkg-config, musl-fts, gnulib, freebsd, libintl
, musl-obstack, m4, zlib, zstd, bzip2, bison, flex, gettext, xz, setupDebugInfoDirs
, argp-standalone
, enableDebuginfod ? lib.meta.availableOn stdenv.hostPlatform libarchive && !stdenv.hostPlatform.isFreeBSD
, sqlite, curl, libmicrohttpd, libarchive
, gitUpdater, autoreconfHook
}:

# TODO: Look at the hardcoded paths to kernel, modules etc.
stdenv.mkDerivation rec {
  pname = "elfutils";
  version = "0.191";

  src = fetchurl {
    url = "https://sourceware.org/elfutils/ftp/${version}/${pname}-${version}.tar.bz2";
    hash = "sha256-33bbcTZtHXCDZfx6bGDKSDmPFDZ+sriVTvyIlxR62HE=";
  };

  patches = [
    ./debug-info-from-env.patch
    (fetchpatch {
      name = "fix-aarch64_fregs.patch";
      url = "https://git.alpinelinux.org/aports/plain/main/elfutils/fix-aarch64_fregs.patch?id=2e3d4976eeffb4704cf83e2cc3306293b7c7b2e9";
      sha256 = "zvncoRkQx3AwPx52ehjA2vcFroF+yDC2MQR5uS6DATs=";
    })
    (fetchpatch {
      name = "musl-asm-ptrace-h.patch";
      url = "https://git.alpinelinux.org/aports/plain/main/elfutils/musl-asm-ptrace-h.patch?id=2e3d4976eeffb4704cf83e2cc3306293b7c7b2e9";
      sha256 = "8D1wPcdgAkE/TNBOgsHaeTZYhd9l+9TrZg8d5C7kG6k=";
    })
    (fetchpatch {
      name = "musl-macros.patch";
      url = "https://git.alpinelinux.org/aports/plain/main/elfutils/musl-macros.patch?id=2e3d4976eeffb4704cf83e2cc3306293b7c7b2e9";
      sha256 = "tp6O1TRsTAMsFe8vw3LMENT/vAu6OmyA8+pzgThHeA8=";
    })
    (fetchpatch {
      name = "musl-strndupa.patch";
      url = "https://git.alpinelinux.org/aports/plain/main/elfutils/musl-strndupa.patch?id=2e3d4976eeffb4704cf83e2cc3306293b7c7b2e9";
      sha256 = "sha256-7daehJj1t0wPtQzTv+/Rpuqqs5Ng/EYnZzrcf2o/Lb0=";
    })
  ] ++ lib.optionals stdenv.hostPlatform.isMusl [ ./musl-error_h.patch ]
    # Prevent headers and binaries from colliding which results in an error.
    # https://sourceware.org/pipermail/elfutils-devel/2024q3/007281.html
    ++ lib.optional (stdenv.targetPlatform.useLLVM or false) ./cxx-header-collision.patch
    ++ lib.optionals stdenv.hostPlatform.isFreeBSD [
      (freebsd.freebsd-lib.fetchPortsPatch {
        url = "https://raw.githubusercontent.com/freebsd/freebsd-ports/ed3a65c936adead5ef586d5121aebed85585a75e/devel/elfutils/files/patch-configure.ac";
        hash = "sha256-RLkpY47N/WkYvEgQtef/jAJawGILE5cKlnOZieHGzhM=";
      })
      (freebsd.freebsd-lib.fetchPortsPatch {
        url = "https://raw.githubusercontent.com/freebsd/freebsd-ports/412c9ba424c45d482bb7ca2740933cebcca5bacf/devel/elfutils/files/patch-lib_eu-config.h";
        hash = "sha256-Om8FjhbN6BKEdPO2R1B2pglDKgOo7akeUYzsHicYr2I=";
      })
      (freebsd.freebsd-lib.fetchPortsPatch {
        url = "https://raw.githubusercontent.com/freebsd/freebsd-ports/adf6019c3c9053e617353dfb9f0843e4880ab4ae/devel/elfutils/files/patch-lib_stdio__ext.h";
        hash = "sha256-GY0jKPdh6QNgFkDLuW3DdL/Ch5pW0yPGWJKg2PrFs6c=";
      })
      (freebsd.freebsd-lib.fetchPortsPatch {
        url = "https://raw.githubusercontent.com/freebsd/freebsd-ports/2c1e4c5f2dda0912ede3a03515b54a99eea90997/devel/elfutils/files/patch-libelf_elf.h";
        hash = "sha256-uCPef/WnmQoiwIQ7bGbAJFxXgEs5Aio5X7t9VC0uDKg=";
      })
      (freebsd.freebsd-lib.fetchPortsPatch {
        url = "https://raw.githubusercontent.com/freebsd/freebsd-ports/2c1e4c5f2dda0912ede3a03515b54a99eea90997/devel/elfutils/files/patch-libelf_gelf.h";
        hash = "sha256-2/F5SOtCbQrNN4GtZ4OTDxvMj8KY55oBXB1seK2RI5Y=";
      })
  ];

  postPatch = ''
    patchShebangs tests/*.sh
  '' + lib.optionalString stdenv.hostPlatform.isRiscV ''
    # disable failing test:
    #
    # > dwfl_thread_getframes: No DWARF information found
    sed -i s/run-backtrace-dwarf.sh//g tests/Makefile.in
  '' + lib.optionalString stdenv.hostPlatform.isFreeBSD (
    # alloca is part of stdlib.h here
  ''
    sed -E -i -e "/alloca.h/d" lib/libeu.h
  ''
    # one of the ports patches targets an older version which interacts poorly with a #pragma poision directive
  + ''
    sed -E -i -e '/^#define.*basename.*eu_basename$/d' lib/eu-config.h
  ''
    # C compilers are strict
  + ''
    substituteInPlace lib/eu-config.h --replace-fail 'return (memchr(s, c, SSIZE_MAX))' 'return ((void*)memchr(s, c, SSIZE_MAX))'
  '') + lib.optionalString (!enableDebuginfod) ''
    sed -E -i -e '/size_t BUFFER_SIZE/d' src/srcfiles.cxx
  '';

  outputs = [ "bin" "dev" "out" "man" ];

  # We need bzip2 in NativeInputs because otherwise we can't unpack the src,
  # as the host-bzip2 will be in the path.
  nativeBuildInputs = [ m4 bison flex gettext bzip2 ]
    ++ lib.optional (enableDebuginfod || stdenv.targetPlatform.useLLVM or false) pkg-config
    ++ lib.optional (stdenv.targetPlatform.useLLVM or false) autoreconfHook;
  buildInputs = [ zlib zstd bzip2 xz ]
    ++ lib.optionals stdenv.hostPlatform.isMusl [
    argp-standalone
    musl-fts
    musl-obstack
  ] ++ lib.optionals enableDebuginfod [
    sqlite
    curl
    libmicrohttpd
    libarchive
  ] ++ lib.optionals stdenv.hostPlatform.isFreeBSD [
    argp-standalone
    libintl
    musl-obstack
  ];

  propagatedNativeBuildInputs = [ setupDebugInfoDirs ];

  env = lib.optionalAttrs stdenv.hostPlatform.isFreeBSD {
    NIX_CFLAGS_COMPILE = "-Wno-error=format-nonliteral -DFREEBSD_HAS_MEMPCPY -D_GL_CONFIG_H_INCLUDED";
    NIX_LDFLAGS = "-lobstack";
  };

  configureFlags = [
    "--program-prefix=eu-" # prevent collisions with binutils
    "--enable-deterministic-archives"
    (lib.enableFeature enableDebuginfod "libdebuginfod")
    (lib.enableFeature enableDebuginfod "debuginfod")

    # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=101766
    # Versioned symbols are nice to have, but we can do without.
    (lib.enableFeature (!stdenv.hostPlatform.isMicroBlaze) "symbol-versioning")
  ] ++ lib.optional (stdenv.targetPlatform.useLLVM or false) "--disable-demangler"
    ++ lib.optionals stdenv.cc.isClang [
      "CFLAGS=-Wno-unused-private-field"
      "CXXFLAGS=-Wno-unused-private-field"
    ];

  enableParallelBuilding = true;


  doCheck =
    # Backtrace unwinding tests rely on glibc-internal symbol names.
    # Musl provides slightly different forms and fails.
    # Let's disable tests there until musl support is fully upstreamed.
    !stdenv.hostPlatform.isMusl
    # Test suite tries using `uname` to determine whether certain tests
    # can be executed, so we need to match build and host platform exactly.
    && (stdenv.hostPlatform == stdenv.buildPlatform);
  doInstallCheck = !stdenv.hostPlatform.isMusl
    && (stdenv.hostPlatform == stdenv.buildPlatform);

  passthru.updateScript = gitUpdater {
    url = "https://sourceware.org/git/elfutils.git";
    rev-prefix = "elfutils-";
  };

  meta = with lib; {
    homepage = "https://sourceware.org/elfutils/";
    description = "Set of utilities to handle ELF objects";
    platforms = platforms.linux ++ platforms.freebsd;
    # https://lists.fedorahosted.org/pipermail/elfutils-devel/2014-November/004223.html
    badPlatforms = [ lib.systems.inspect.platformPatterns.isStatic ];
    # licenses are GPL2 or LGPL3+ for libraries, GPL3+ for bins,
    # but since this package isn't split that way, all three are listed.
    license = with licenses; [ gpl2Only lgpl3Plus gpl3Plus ];
    maintainers = with maintainers; [ r-burns ];
  };
}
