{
  mkKdeDerivation,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "polkit-kde-agent-1";

  extraNativeBuildInputs = [ qtdeclarative ];
}
