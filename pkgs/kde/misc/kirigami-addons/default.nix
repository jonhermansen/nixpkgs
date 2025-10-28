{
  lib,
  mkKdeDerivation,
  fetchurl,
  qtdeclarative,
  qt5compat,
  pkgsBuildHost,
}:
mkKdeDerivation rec {
  pname = "kirigami-addons";
  version = "1.8.1";

  src = fetchurl {
    url = "mirror://kde/stable/kirigami-addons/kirigami-addons-${version}.tar.xz";
    hash = "sha256-AAKK5N+Z4lBRg0XqKNnN9J1wDprKxIJzS7UThNoR+UU=";
  };

  extraNativeBuildInputs = [ (pkgsBuildHost.kdePackages.qttools.override { withClang = true; }) qtdeclarative ];
  extraBuildInputs = [ qtdeclarative ];
  extraPropagatedBuildInputs = [ qt5compat ];
  extraCmakeFlags = [
    # wrong gettext is earlier in $PATH
    "-DGETTEXT_MSGFMT_EXECUTABLE=${pkgsBuildHost.gettext}/bin/msgfmt"
  ];

  meta.license = with lib.licenses; [
    bsd2
    cc-by-sa-40
    cc0
    gpl2Plus
    lgpl2Only
    lgpl2Plus
    lgpl21Only
    lgpl21Plus
    lgpl3Only
  ];
}
