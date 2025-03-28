{
  mkKdeDerivation,
  qttools,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "kxmlgui";

  extraBuildInputs = [ qttools ];
  extraNativeBuildInputs = [
    qtdeclarative
  ];
}
