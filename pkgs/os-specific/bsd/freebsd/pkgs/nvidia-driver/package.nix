{
  lib,
  mkDerivation,
  fetchurl,
  sys,
  drm-kmod,
  xargs-j,
}:
mkDerivation rec {
  path = "...";
  pname = "nvidia-driver";
  version = "570.124.04";
  src = fetchurl {
    url = "https://us.download.nvidia.com/XFree86/FreeBSD-x86_64/${version}/NVIDIA-FreeBSD-x86_64-${version}.tar.xz";
    hash = "sha256-3FNJPZWg23H/YiUdIfO4KOUZ7BrJ2/xw8LD6MMSEICY=";
  };

  extraNativeBuildInputs = [
    xargs-j
  ];

  preConfigure = ''
    cd src
  '';

  makeFlags = [
    "BSDSRCTOP=${sys.src}"
    "SYSDIR=${sys.src}/sys"
    "DRMKMODDIR=${drm-kmod.src}"
    "KMODDIR=${builtins.placeholder "out"}/kernel"
    "NO_XREF=1"
  ];

  hardeningDisable = [
    "pic" # generates relocations the linker can't handle
  ];

  meta.platforms = [ "x86_64-freebsd" ];
  meta.license = lib.licenses.unfree;
}
