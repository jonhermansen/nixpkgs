{
  mkKdeDerivation,
  qttools,
  qtdeclarative,
  qtwayland,
  pkg-config,
}:
mkKdeDerivation {
  pname = "kwindowsystem";

  extraNativeBuildInputs = [
    qttools
    pkg-config
    qtwayland
  ];
  extraBuildInputs = [
    qtdeclarative
    qtwayland
  ];
}
