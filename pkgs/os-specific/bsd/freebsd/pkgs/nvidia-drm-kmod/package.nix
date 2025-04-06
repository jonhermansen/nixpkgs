{
  lib,
  mkDerivation,
  fetchurl,
  sys,
  drm-kmod,
  xargs-j,
  kldxref,
}:
mkDerivation rec {
  path = "...";
  pname = "nvidia-drm-kmod";
  version = "570.133.07";
  src = fetchurl {
    url = "https://us.download.nvidia.com/XFree86/FreeBSD-x86_64/${version}/NVIDIA-FreeBSD-x86_64-${version}.tar.xz";
    hash = "sha256-239UnKG2EIJJ+96bZBBY1GzQCUGQR13ZYfeY9A7adsw=";
  };

  extraNativeBuildInputs = [
    xargs-j
    kldxref
  ];

  makeFlags = [
    "BSDSRCTOP=${sys.src}"
    "SYSDIR=${sys.src}/sys"
    "DRMKMODDIR=${drm-kmod.src}"
    "KMODDIR=${builtins.placeholder "out"}/kernel"
  ];

  preConfigure = ''
    cd src
  '';

  meta.platforms = [ "x86_64-freebsd" ];
  meta.license = lib.licenses.unfree;
}
