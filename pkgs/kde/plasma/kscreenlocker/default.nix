{
  mkKdeDerivation,
  pam,
  wayland-scanner,
  qqc2-breeze-style,
  qtdeclarative,
  kdeHostTools,
}:
mkKdeDerivation {
  pname = "kscreenlocker";

  extraNativeBuildInputs = [
    wayland-scanner
    qtdeclarative
    kdeHostTools
  ];
  extraBuildInputs = [
    pam
    qqc2-breeze-style
  ];
}
