{
  mkKdeDerivation,
  kio,
  kdeHostTools,
}:
mkKdeDerivation {
  pname = "dolphin";

  extraNativeBuildInputs = [
    kdeHostTools
    kio
  ];
}
