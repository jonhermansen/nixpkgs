{
  mkDerivation,
  libjail,
  libutil,
  libsbuf,
  ...
}:
mkDerivation {
  path = "usr.bin/top";
  buildInputs = [
    libjail
    libutil
    libsbuf
  ];
}
