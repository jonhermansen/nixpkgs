{
  mkKdeDerivation,
  qtdeclarative,
  kdeHostTools,
}:
mkKdeDerivation {
  pname = "plasma-systemmonitor";

  extraNativeBuildInputs = [
    qtdeclarative
    kdeHostTools
  ];
  meta.mainProgram = "plasma-systemmonitor";
}
