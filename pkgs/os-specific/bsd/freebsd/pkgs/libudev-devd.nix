{ lib, stdenv, fetchFromGitHub, evdev-proto, autoreconfHook, fetchpatch }:

stdenv.mkDerivation rec {
  pname = "libudev-devd";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "wulf7";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-CrRPJMJRYiYyEIy5XPFk286S87/paf6OfGkEdRPv28I=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/rhelmot/libudev-devd/commit/b0e522c90476aac834368cb42032f57a3689dd7b.patch";
      hash = "sha256-j0EPJHuBA44U5DfRLn8+Ffrwm02R7BBYZE+kZ9fdSis=";
    })
    (fetchpatch {
      url = "https://github.com/rhelmot/libudev-devd/commit/ddf106985b7b12684626fa1a2b4d151cd96ecaed.patch";
      hash = "sha256-2Kyxid+V8bwKBrLNMGhKUpb1mB5NnKwVEFcKbdHF9JQ=";
    })
  ];

  buildInputs = [ evdev-proto ];
  nativeBuildInputs = [ autoreconfHook ];

  env = {
    #CFLAGS = "-Wno-error=array-parameter";
  };

  #makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    homepage = "https://github.com/wulf7/libudev-devd";
    description = "libudev-compatible interface for devd";
    maintainers = with maintainers; [ rhelmot ];
    license = licenses.bsd2;
    platforms = platforms.freebsd;
  };
}
