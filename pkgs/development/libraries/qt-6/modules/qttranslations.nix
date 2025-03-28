{
  qtModule,
  qtbase,
  qttools,
}:

qtModule {
  pname = "qttranslations";
  nativeBuildInputs = [
    qtbase
    qttools
  ];
  outputs = [ "out" ];
}
