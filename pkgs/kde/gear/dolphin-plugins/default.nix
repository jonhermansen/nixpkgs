{
  mkKdeDerivation,
  qttools,
  kdeHostTools,
}:
mkKdeDerivation {
  pname = "dolphin-plugins";

  extraNativeBuildInputs = [
    kdeHostTools
    qttools
  ];
}
