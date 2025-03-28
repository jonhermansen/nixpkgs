{
  mkKdeDerivation,
  qt5compat,
  qtmultimedia,
  kxmlgui,
  kdeHostTools,
}:
mkKdeDerivation {
  pname = "konsole";

  extraNativeBuildInputs = [
    kxmlgui
    kdeHostTools
  ];
  extraBuildInputs = [
    qt5compat
    qtmultimedia
  ];

  meta.mainProgram = "konsole";
}
