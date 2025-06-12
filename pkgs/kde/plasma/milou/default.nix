{
  mkKdeDerivation,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "milou";

  extraNativeBuildInputs = [
    qtdeclarative
  ];
}
