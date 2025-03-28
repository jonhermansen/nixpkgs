{
  lib,
  stdenv,
  mkKdeDerivation,
  pkg-config,
  libksysguard,
  networkmanager-qt,
  lm_sensors,
  libnl,
  kio,
  freebsd,
}:
mkKdeDerivation {
  pname = "ksystemstats";

  extraNativeBuildInputs = [
    pkg-config
    kio
  ];
  extraBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    lm_sensors
    libnl
    networkmanager-qt
  ]
  ++ lib.optionals stdenv.hostPlatform.isFreeBSD [
    freebsd.libdevinfo
    freebsd.libgeom
  ];

  cmakeFlags = [
    "-DSYSTEMSTATS_DBUS_INTERFACE=${libksysguard}/share/dbus-1/interfaces/org.kde.ksystemstats1.xml"
  ];
}
