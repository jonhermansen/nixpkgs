{
  mkKdeDerivation,
  qtwebsockets,
  kdeclarative,
  kpackage,
  kcmutils,
  kdeHostTools,
}:
mkKdeDerivation {
  pname = "kunifiedpush";

  extraNativeBuildInputs = [
    kdeHostTools
    kcmutils
  ];
  extraBuildInputs = [
    qtwebsockets
    kdeclarative
    kpackage
  ];

  meta.mainProgram = "kunifiedpush-distributor";
}
