{
  qtModule,
  qtbase,
  stdenv,
  lib,
  qtshadertools,
}:

qtModule {
  pname = "qtshadertools";
  propagatedBuildInputs = [ qtbase ];
  cmakeFlags = lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    "-DQt6ShaderToolsTools_DIR=${qtshadertools.__spliced.buildHost}/lib/cmake/Qt6ShaderToolsTools"
  ];
  meta.mainProgram = "qsb";
}
