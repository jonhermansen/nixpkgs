{
  mkKdeDerivation,
  qtspeech,
  qttools,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "ktextwidgets";

  extraBuildInputs = [
    qtspeech
    qttools
  ];
  extraNativeBuildInputs = [
    qtdeclarative
  ];
}
