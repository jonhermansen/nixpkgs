{
  mkKdeDerivation,
  kxmlgui,
  kdeHostTools,
}:
mkKdeDerivation {
  pname = "kmenuedit";
  extraNativeBuildInputs = [
    kdeHostTools
    kxmlgui
  ];
  meta.mainProgram = "kmenuedit";
}
