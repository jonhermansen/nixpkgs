{
  stdenv,
  lib,
  versionData,
  mkDerivation,
  libncurses-tinfo,
  include,
  libcMinimal,
  libgcc,
  csu,
}:
mkDerivation {
  path = "lib/ncurses/ncurses";
  extraPaths = [
    "lib/ncurses"
    "contrib/ncurses"
    "lib/Makefile.inc"
  ];

  noLibc = true;
  MK_TESTS = "no";

  preBuild = lib.optionalString (versionData.major >= 14) ''
    export NIX_CFLAGS_COMPILE="$NIX_CFLAGS_COMPILE -B${csu}/lib"
    make -C ../tinfo $makeFlags curses.h ncurses_dll.h ncurses_def.h
  '';
  buildInputs = lib.optionals (versionData.major >= 14) [ libncurses-tinfo ]
  ++ [
    include
    libcMinimal
    libgcc
  ];

  # some packages depend on libncursesw.so.8
  postInstall = if stdenv.hostPlatform.isStatic then ''
    rm $out/lib/lib*.so*
  '' else ''
    ln -s $out/lib/libncursesw.so.9 $out/lib/libncursesw.so.8
  '';
}
