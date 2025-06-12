{
  mkKdeDerivation,
  qtsvg,
  kio,
  kdeHostTools,
}:
mkKdeDerivation {
  pname = "kde-cli-tools";

  extraNativeBuildInputs = [
    kdeHostTools
    kio
  ];
  extraBuildInputs = [ qtsvg ];
}
