{
  mkKdeDerivation,
  libgcrypt,
  kdoctools,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "kwallet";

  extraBuildInputs = [
    libgcrypt
  ];

  extraNativeBuildInputs = [
    kdoctools
    qtdeclarative
  ];
}
