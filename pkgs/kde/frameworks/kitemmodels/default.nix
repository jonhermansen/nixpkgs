{
  mkKdeDerivation,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "kitemmodels";

  extraBuildInputs = [ qtdeclarative ];
  extraNativeBuildInputs = [ qtdeclarative ];
}
