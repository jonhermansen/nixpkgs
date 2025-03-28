{
  mkKdeDerivation,
  qtdeclarative,
  kaccounts-integration,
  kdeclarative,
  prison,
}:
mkKdeDerivation {
  pname = "purpose";

  extraNativeBuildInputs = [
    qtdeclarative
  ];
  extraPropagatedBuildInputs = [
    kaccounts-integration
    kdeclarative
    prison
  ];
}
