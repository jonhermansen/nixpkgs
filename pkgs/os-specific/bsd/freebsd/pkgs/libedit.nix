{
  mkDerivation
}:
mkDerivation {
  path = "lib/libedit";
  extraPaths = [ "contrib/libedit" ];
  MK_TESTS = "no";
}
