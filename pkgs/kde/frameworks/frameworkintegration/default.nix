{
  mkKdeDerivation,
  pkg-config,
  packagekit-qt,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "frameworkintegration";

  extraNativeBuildInputs = [ pkg-config qtdeclarative ];
  extraBuildInputs = [ packagekit-qt ];
}
