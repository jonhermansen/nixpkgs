{
  stdenv,
  lib,
  mkKdeDerivation,
  qt5compat,
  qtdeclarative,
  qttools,
  acl,
  attr,
  kdeHostTools,
}:
mkKdeDerivation {
  pname = "kio";

  patches = [
    # Remove hardcoded smbd search path
    ./0001-Remove-impure-smbd-search-path.patch
    # Allow loading kio-admin from the store
    ./allow-admin-from-store.patch
  ];

  extraNativeBuildInputs = [
    qtdeclarative
    (kdeHostTools.override {
      kcmutils = null;
    })
  ];

  extraBuildInputs = [
    qt5compat
    qttools
  ]
  ++ lib.optional (lib.meta.availableOn stdenv.hostPlatform acl) acl
  ++ lib.optional (lib.meta.availableOn stdenv.hostPlatform attr) attr
  ;
}
