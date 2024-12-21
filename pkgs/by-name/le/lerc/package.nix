{ lib
, stdenv
, freebsd
, fetchFromGitHub
, fetchpatch
, cmake
, testers
, dos2unix
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lerc";
  version = "4.0.0";

  outputs = [ "out" "dev" ];

  src = fetchFromGitHub {
    owner = "esri";
    repo = "lerc";
    rev = "v${finalAttrs.version}";
    hash = "sha256-IHY9QtNYsxPz/ksxRMZGHleT+/bawfTYNVRSTAuYQ7Y=";
  };

  patches = [
    # https://github.com/Esri/lerc/pull/227
    (fetchpatch {
      name = "use-cmake-install-full-dir.patch";
      url = "https://github.com/Esri/lerc/commit/5462ca7f7dfb38c65e16f5abfd96873af177a0f8.patch";
      hash = "sha256-qaNR3QwLe0AB6vu1nXOh9KhlPdWM3DmgCJj4d0VdOUk=";
    })
  ] ++ lib.optionals stdenv.hostPlatform.isFreeBSD [
    (freebsd.freebsd-lib.fetchPortsPatch {
      url = "https://raw.githubusercontent.com/freebsd/freebsd-ports/2c82e20330b9bf3fa0475d5bdd390577f374faa5/graphics/lerc/files/patch-_assert";
      hash = "sha256-FVoxKGcuu98AMrExBdzFAEznYCxQsfb8gZUdPm3q3Pk=";
    })
  ];

  prePatch = ''
    dos2unix src/LercLib/fpl_Lerc2Ext.cpp
  '';

  nativeBuildInputs = [
    cmake
    dos2unix
  ];

  passthru.tests.pkg-config = testers.hasPkgConfigModules {
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "C++ library for Limited Error Raster Compression";
    homepage = "https://github.com/esri/lerc";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
    pkgConfigModules = [ "Lerc" ];
  };
})
