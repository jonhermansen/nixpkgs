{
  mkKdeDerivation,
  fetchurl,
  lib,
  extra-cmake-modules,
  qtbase,
}:

mkKdeDerivation rec {
  pname = "plasma-wayland-protocols";
  version = "1.16.0";

  src = fetchurl {
    url = "mirror://kde/stable/${pname}/${pname}-${version}.tar.xz";
    hash = "sha256-2j+74/pWA/ncmqvpSKb8jDtFHt0ZWBOGKOlsg2ScHxY=";
  };

  extraNativeBuildInputs = [ extra-cmake-modules ];

  extraBuildInputs = [ qtbase ];

  meta.license = lib.licenses.lgpl21Plus;
}
