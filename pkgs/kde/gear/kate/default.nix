{
  mkKdeDerivation,
  ktexteditor,
  kdeHostTools,
}:
mkKdeDerivation {
  pname = "kate";

  extraNativeBuildInputs = [
    kdeHostTools
    ktexteditor
  ];
}
