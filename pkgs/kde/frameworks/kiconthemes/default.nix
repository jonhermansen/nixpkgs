{
  mkKdeDerivation,
  qtdeclarative,
  qtsvg,
  qttools,
}:
mkKdeDerivation {
  pname = "kiconthemes";

  extraBuildInputs = [
    qtdeclarative
    qtsvg
    qttools
  ];
  extraNativeBuildInputs = [
    qtdeclarative
  ];
  meta.mainProgram = "kiconfinder6";
}
