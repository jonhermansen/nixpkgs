{
  mkKdeDerivation,
  qttools,
  qtdeclarative
}:
mkKdeDerivation {
  pname = "kconfigwidgets";

  extraBuildInputs = [ qttools ];
  extraNativeBuildInputs = [ qtdeclarative ];
}
