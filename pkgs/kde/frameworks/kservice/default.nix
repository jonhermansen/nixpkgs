{
  qtdeclarative,
  mkKdeDerivation,
  pkgsBuildHost,
}:
mkKdeDerivation {
  pname = "kservice";

  # FIXME(later): upstream
  patches = [
    # follow symlinks when generating sycoca
    ./qdiriterator-follow-symlinks.patch
    # explode less when sycoca is deleted
    ./handle-sycoca-deletion.patch
  ];
  extraNativeBuildInputs = [
    qtdeclarative
    (pkgsBuildHost.kdePackages.kdeHostTools.override {
      kcmutils = null;
    })
  ];
  meta.mainProgram = "kbuildsycoca6";
}
