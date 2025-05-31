{
  mkKdeDerivation,
  replaceVars,
  ghostscript,
  kio,
}:
mkKdeDerivation {
  pname = "kdegraphics-thumbnailers";

  extraNativeBuildInputs = [
    kio
  ];

  patches = [
    # Hardcode patches to Ghostscript so PDF thumbnails work OOTB.
    # Intentionally not doing the same for dvips because TeX is big.
    (replaceVars ./gs-paths.patch {
      gs = "${ghostscript}/bin/gs";
    })
  ];
}
