{
  mkKdeDerivation,
  qtdeclarative,
  kdeHostTools,
}:
mkKdeDerivation {
  pname = "systemsettings";
  extraNativeBuildInputs = [
    qtdeclarative
    kdeHostTools
  ];
  meta.mainProgram = "systemsettings";
}
