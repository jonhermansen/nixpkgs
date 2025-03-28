{
  lib,
  stdenv,
  fetchurl,
  pam,
}:

stdenv.mkDerivation rec {
  pname = "pam_xdg";
  version = "0.8.5";
  src = fetchurl {
    url = "https://ftp.sdaoden.eu/${pname}-${version}.tar.gz";
    hash = "sha256-o4Fol6LouBQVLiGMAszEB+zBkBj8C1xMp057AvH3nl4=";
  };

  buildInputs = [
    pam
  ];

  makeFlags = [
    "PREFIX=${builtins.placeholder "out"}"
    "MANPREFIX=${builtins.placeholder "out"}"
    "XDG_RUNTIME_DIR_OUTER=/var/run"
    "XDG_DATA_DIR_LOCAL=/run/current-system/sw"
  ];
}
