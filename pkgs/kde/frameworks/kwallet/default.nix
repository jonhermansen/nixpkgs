{
  mkKdeDerivation,
  pkg-config,
  libgcrypt,
  libsecret,
  kdoctools,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "kwallet";

  extraNativeBuildInputs = [
    pkg-config
    qtdeclarative
    kdoctools
  ];

  extraBuildInputs = [
    libgcrypt
    libsecret

  ];
}
