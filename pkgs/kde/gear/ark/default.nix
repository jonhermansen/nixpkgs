{
  mkKdeDerivation,
  libarchive,
  libzip,
  kio,
  kdeHostTools,
}:
mkKdeDerivation {
  pname = "ark";

  extraNativeBuildInputs = [
    kdeHostTools
    kio
  ];
  extraBuildInputs = [
    libarchive
    (libzip.override { withOpenssl = true; })
  ];
  meta.mainProgram = "ark";
}
