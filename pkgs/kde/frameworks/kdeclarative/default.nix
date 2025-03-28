{
  mkKdeDerivation,
  qtdeclarative,
  spirv-tools,
}:
mkKdeDerivation {
  pname = "kdeclarative";

  extraNativeBuildInputs = [ spirv-tools qtdeclarative ];
  extraBuildInputs = [ qtdeclarative ];
}
