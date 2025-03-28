{
  stdenv,
  lib,
  mkKdeDerivation,
  fetchurl,
  doxygen,
  kdsoap,
}:
mkKdeDerivation rec {
  pname = "kdsoap-ws-discovery-client";
  version = "0.4.0";

  src = fetchurl {
    url = "mirror://kde/stable/kdsoap-ws-discovery-client/kdsoap-ws-discovery-client-${version}.tar.xz";
    hash = "sha256-LNJHwBPnX0EGWbrDcq/5PSLXHFpUwFnhN7lESvizQno=";
  };

  extraNativeBuildInputs = [ doxygen ];

  postPatch = lib.optionalString (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    cmakeFlags+=" -DKDSOAP_KDWSDL2CPP_COMPILER=$(echo ${kdsoap.__spliced.buildHost.dev}/bin/kdwsdl2cpp*)"
  '';

  meta.license = [ lib.licenses.gpl3Plus ];
}
