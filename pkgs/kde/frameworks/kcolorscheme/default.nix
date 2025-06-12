{ mkKdeDerivation, qtdeclarative }:
mkKdeDerivation {
  pname = "kcolorscheme";
  extraNativeBuildInputs = [
    qtdeclarative
  ];
}
