{
  mkKdeDerivation,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "qqc2-breeze-style";
  extraNativeBuildInputs = [
    qtdeclarative
  ];
}
