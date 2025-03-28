{
  mkKdeDerivation,
  kxmlgui,
  kdeHostTools,
}:
mkKdeDerivation {
  pname = "kwalletmanager";

  extraNativeBuildInputs = [
    kxmlgui
    kdeHostTools
  ];

  meta.mainProgram = "kwalletmanager5";
}
