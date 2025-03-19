{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  v4l-compat,
  autoreconfHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "libudev-devd";
  version = "0.5.0";
  src = fetchFromGitHub {
    owner = "wulf7";
    repo = "libudev-devd";
    rev = "3a5a11ec875de4f2c5d6d0a7055432fea26d7778";
    hash = "sha256-bnwjGI9TaFyHgZevkrn12kBXD9bSHrhvyygTMs2lc60=";
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

  nativeBuildInputs = [
    autoreconfHook
  ];

  buildInputs = [
    v4l-compat
  ];

  meta = {
    description = "libudev-compatible interface for devd";
    maintainers = [ lib.maintainers.rhelmot ];
    platforms = lib.platforms.freebsd;
    license = lib.licenses.bsd2;
    pkgConfigModules = [ "libudev" ];
  };
})
