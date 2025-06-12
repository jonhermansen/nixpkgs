{
  mkDerivation,
  libncurses-tinfo,
  libncurses,
  libncurses-form,
}:
mkDerivation {
  path = "lib/libbsddialog";
  extraPaths = [
    "contrib/bsddialog"
  ];
  outputs = [
    "out"
    "man"
    "debug"
  ];
  buildInputs = [
    libncurses-tinfo
    libncurses
    libncurses-form
  ];
  postFixup = ''
    mv $out/include/private/bsddialog/* $out/include
    rm -rf $out/include/private
  '';
}
