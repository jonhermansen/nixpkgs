{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libpthreadstubs,
  qtbase,
  qtwebsockets,
  wrapQtAppsHook,
  qtdeclarative,
}:

stdenv.mkDerivation rec {
  pname = "qcoro";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "danvratil";
    repo = "qcoro";
    rev = "v${version}";
    sha256 = "sha256-NF+va2pS2NJt4OE+yfN/jVnfkueBdjoyg2lQJhMRWe4=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    wrapQtAppsHook
    cmake
    qtdeclarative
  ];

  buildInputs = [
    qtbase
    qtwebsockets
    libpthreadstubs
  ];

  meta = with lib; {
    description = "Library for using C++20 coroutines in connection with certain asynchronous Qt actions";
    homepage = "https://github.com/danvratil/qcoro";
    license = licenses.mit;
    maintainers = with maintainers; [ smitop ];
    platforms = platforms.linux ++ platforms.freebsd;
  };
}
