{
  mkKdeDerivation,
  qtsvg,
  qtwayland,
  qtimageformats,
  pkg-config,
  cfitsio,
  exiv2,
  baloo,
  kimageannotator,
  lcms2,
  libtiff,
  kdeHostTools,
}:
mkKdeDerivation {
  pname = "gwenview";

  extraNativeBuildInputs = [
    kdeHostTools
    pkg-config
    qtwayland
  ];
  extraBuildInputs = [
    qtsvg
    qtwayland
    # adds support for webp and other image formats
    qtimageformats

    cfitsio
    exiv2
    baloo
    kimageannotator
    lcms2
    libtiff
  ];
}
