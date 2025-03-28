{
  mkKdeDerivation,
  qt5compat,
  boost,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "kactivitymanagerd";

  extraBuildInputs = [
    qt5compat
    boost
  ];
  extraNativeBuildInputs = [
    qtdeclarative
  ];
}
