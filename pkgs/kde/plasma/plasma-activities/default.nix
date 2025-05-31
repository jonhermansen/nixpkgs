{
  mkKdeDerivation,
  qtdeclarative,
  boost,
}:
mkKdeDerivation {
  pname = "plasma-activities";

  extraBuildInputs = [
    qtdeclarative
    boost
  ];
  extraNativeBuildInputs = [
    qtdeclarative
  ];
  meta.mainProgram = "plasma-activities-cli6";
}
