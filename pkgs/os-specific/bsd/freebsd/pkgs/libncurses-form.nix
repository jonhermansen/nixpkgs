{
  mkDerivation,
}:
mkDerivation {
  pname = "ncurses-form";
  path = "lib/ncurses/form";
  extraPaths = [
    "lib/ncurses"
    "contrib/ncurses"
    "lib/Makefile.inc"
  ];
}
