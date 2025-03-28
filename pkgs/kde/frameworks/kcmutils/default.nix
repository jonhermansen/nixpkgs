{
  mkKdeDerivation,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "kcmutils";

  extraPropagatedBuildInputs = [ qtdeclarative ];
  extraNativeBuildInputs = [
    qtdeclarative
  ];
  meta.mainProgram = "kcmshell6";
}
