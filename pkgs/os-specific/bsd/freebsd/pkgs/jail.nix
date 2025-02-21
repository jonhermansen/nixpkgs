{
  lib,
  mkDerivation,
  flex,
  byacc,
  libjail,
}:
mkDerivation {
  path = "usr.sbin/jail";
  extraNativeBuildInputs = [
    flex
    byacc
  ];
  buildInputs = [
    libjail
  ];
  postPatch = ''
    substituteInPlace $BSDSRCDIR/usr.sbin/jail/command.c --replace "/sbin/" "" --replace _PATH_MOUNT '"mount"'
  '';
  MK_TESTS = "no";
  meta.mainProgram = "jail";
  meta.platforms = lib.platforms.freebsd;
}
