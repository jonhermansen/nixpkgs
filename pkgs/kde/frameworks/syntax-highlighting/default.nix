{
  lib,
  stdenv,
  mkKdeDerivation,
  qtdeclarative,
  qttools,
  perl,
  syntax-highlighting
}:
mkKdeDerivation {
  pname = "syntax-highlighting";

  extraBuildInputs = [ qtdeclarative ];
  extraNativeBuildInputs = [
    qttools
    perl
  ];
  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    cp bin/katehighlightingindexer $out/bin
  '';
  extraCmakeFlags = lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    "-DKATEHIGHLIGHTINGINDEXER_EXECUTABLE=${syntax-highlighting.__spliced.buildHost or syntax-highlighting}/bin/katehighlightingindexer"
  ];
  meta.mainProgram = "ksyntaxhighlighter6";
}
