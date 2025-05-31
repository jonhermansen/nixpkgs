{
  mkKdeDerivation,
  qtdeclarative,
  qtspeech,
  editorconfig-core-c,
  kdeHostTools,
}:
mkKdeDerivation {
  pname = "ktexteditor";

  extraBuildInputs = [
    qtspeech
    editorconfig-core-c
  ];
  extraNativeBuildInputs = [
    qtdeclarative
    kdeHostTools
  ];
}
