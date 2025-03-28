{
  lib,
  stdenv,
  mkKdeDerivation,
  kio,
}:
mkKdeDerivation {
  pname = "kio-admin";
  extraNativeBuildInputs = [
    kio
  ];

  # unconditionally tries to link gcc libatomic
  postPatch = lib.optionalString stdenv.hostPlatform.isFreeBSD ''
    substituteInPlace src/CMakeLists.txt --replace-fail atomic compiler_rt
  '';
}
