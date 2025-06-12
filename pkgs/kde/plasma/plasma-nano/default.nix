{
  mkKdeDerivation,
  qtsvg,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "plasma-nano";

  extraBuildInputs = [ qtsvg ];
  extraNativeBuildInputs = [ qtdeclarative ];
}
