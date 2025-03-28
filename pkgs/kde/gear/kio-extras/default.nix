{
  lib,
  stdenv,
  mkKdeDerivation,
  qt5compat,
  qtsvg,
  pkg-config,
  samba,
  libssh,
  libmtp,
  libimobiledevice,
  gperf,
  libtirpc,
  openexr_3,
  taglib,
  shared-mime-info,
  libappimage,
  xorg,
  kio,
  kconfig,
  kdoctools,
  kauth,
  kcmutils,
  kpackage,
  symlinkJoin,
}:
let
  hostTools = symlinkJoin {
    pname = "kdoctools-kconfig-kauth";
    inherit (kconfig) version;
    paths = [
      (kdoctools.__spliced.buildHost or kdoctools).dev
      (kconfig.__spliced.buildHost or kconfig).dev
      (kauth.__spliced.buildHost or kauth).dev
      (kcmutils.__spliced.buildHost or kcmutils).dev
      (kpackage.__spliced.buildHost or kpackage).dev
    ];
  };
in
mkKdeDerivation {
  pname = "kio-extras";

  extraNativeBuildInputs = [
    pkg-config
    gperf
    shared-mime-info
    kio
  ];
  extraBuildInputs = [
    qt5compat
    qtsvg

    samba
    libssh
    libmtp
    libimobiledevice
    gperf
    openexr_3
    taglib
    xorg.libXcursor
  ]
  ++ lib.optional (lib.meta.availableOn stdenv.hostPlatform libappimage) libappimage
  ++ lib.optional (lib.meta.availableOn stdenv.hostPlatform libtirpc) libtirpc
  ;

  postInstall = ''
    substituteInPlace $out/share/dbus-1/services/org.kde.kmtpd5.service \
      --replace-fail Exec=$out/libexec/kf6/kiod6 Exec=${kio}/libexec/kf6/kiod6
  '';
  extraCmakeFlags = lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    "-DKF6_HOST_TOOLING=${hostTools}/lib/cmake"
  ];
}
