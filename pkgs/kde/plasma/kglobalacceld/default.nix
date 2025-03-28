{
  mkKdeDerivation,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "kglobalacceld";
  extraNativeBuildInputs = [ qtdeclarative ];
}
