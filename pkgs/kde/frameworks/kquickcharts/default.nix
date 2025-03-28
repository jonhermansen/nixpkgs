{
  mkKdeDerivation,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "kquickcharts";

  extraBuildInputs = [ qtdeclarative ];
  extraNativeBuildInputs = [ qtdeclarative ];
}
