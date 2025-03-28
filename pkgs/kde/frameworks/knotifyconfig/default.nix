{
  mkKdeDerivation,
  libcanberra,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "knotifyconfig";

  extraBuildInputs = [ libcanberra ];
  extraNativeBuildInputs = [
    qtdeclarative
  ];
}
