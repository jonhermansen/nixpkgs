{
  mkKdeDerivation,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "kparts";
  extraNativeBuildInputs = [
    qtdeclarative
  ];
}
