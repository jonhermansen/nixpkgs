{
  qtModule,
  qtbase,
  qtdeclarative,
  qtsvg,
  hunspell,
  pkg-config,
}:

qtModule {
  pname = "qtvirtualkeyboard";
  propagatedBuildInputs = [
    qtbase
    qtdeclarative
    qtsvg
    hunspell
  ];
  buildInputs = [
    qtdeclarative
  ];
  nativeBuildInputs = [
    pkg-config
  ];
  cmakeFlags = [
    #"--trace"
    #"-DQT_DEBUG_FIND_PACKAGE=ON"
    "--debug-find-pkg=Qt6QmlTools"
  ];
  postPatch = ''
    sed -E -i -e '/Quick$/d' -e '/Svg$/d' -e 's/BuildInternals Core/BuildInternals Core Svg Quick/' CMakeLists.txt
  '';
}
