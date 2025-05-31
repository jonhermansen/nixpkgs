{
  mkKdeDerivation,
  qtdeclarative,
  kconfig,
  kdeHostTools,
}:
mkKdeDerivation {
  pname = "kded";

  extraNativeBuildInputs = [
    qtdeclarative
    kdeHostTools
  ];

  extraBuildInputs = [
    kconfig
  ];

  # override cmake, which cannot be convinced that this should be the host and not build kconf_update
  env.NIX_CFLAGS_COMPILE = "-DKCONF_UPDATE_EXE=\"${kconfig}/libexec/kconf_update\"";

  meta.mainProgram = "kded6";
}
