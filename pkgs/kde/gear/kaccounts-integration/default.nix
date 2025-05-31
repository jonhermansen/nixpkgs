{
  mkKdeDerivation,
  intltool,
  qtdeclarative,
  kdeHostTools,
}:
mkKdeDerivation {
  pname = "kaccounts-integration";

  propagatedNativeBuildInputs = [ intltool ];
  extraNativeBuildInputs = [
    qtdeclarative
    kdeHostTools
  ];
}
