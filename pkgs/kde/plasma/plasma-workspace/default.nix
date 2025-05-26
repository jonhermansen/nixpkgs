{
  lib,
  stdenv,
  mkKdeDerivation,
  replaceVars,
  dbus,
  fontconfig,
  xorg,
  lsof,
  pkg-config,
  spirv-tools,
  qtbase,
  qtpositioning,
  qtdeclarative,
  qtsvg,
  qtwayland,
  libcanberra,
  libqalculate,
  pipewire,
  qttools,
  qqc2-breeze-style,
  gpsd,
  kdeHostTools,
}:
mkKdeDerivation {
  pname = "plasma-workspace";

  patches = [
    (replaceVars ./dependency-paths.patch {
      dbusSend = lib.getExe' dbus "dbus-send";
      fcMatch = lib.getExe' fontconfig "fc-match";
      lsof = lib.getExe lsof;
      qdbus = lib.getExe' qttools "qdbus";
      xmessage = lib.getExe xorg.xmessage;
      xrdb = lib.getExe xorg.xrdb;
      # @QtBinariesDir@ only appears in the *removed* lines of the diff
      QtBinariesDir = null;
    })
  ];

  postInstall = ''
    # Prevent patching this shell file, it only is used by sourcing it from /bin/sh.
    chmod -x $out/libexec/plasma-sourceenv.sh
  '';

  excludeDependencies = lib.optionals stdenv.hostPlatform.isFreeBSD [
    "networkmanager-qt"
  ];
  extraNativeBuildInputs = [
    pkg-config
    spirv-tools
    qtdeclarative
    qtwayland
    kdeHostTools
  ];
  extraBuildInputs = [
    qtbase
    qtpositioning
    qtsvg
    qtwayland

    qqc2-breeze-style

    libcanberra
    libqalculate
    pipewire

    xorg.libSM
    xorg.libXcursor
    xorg.libXtst
    xorg.libXft

    gpsd
  ];

  # Hardcoded as QStrings, which are UTF-16 so Nix can't pick these up automatically
  postFixup = ''
    mkdir -p $out/nix-support
    echo "${lsof} ${xorg.xmessage} ${xorg.xrdb}" > $out/nix-support/depends
  ''
  # Picks up the wrong (build-system) qtpaths
  + lib.optionalString (stdenv.buildPlatform != stdenv.hostPlatform) ''
    substituteInPlace $out/share/kconf_update/migrate-calendar-to-plugin-id.py --replace-fail "${qtbase.__spliced.buildHost}" "${qtbase}"
  '';

  passthru.providedSessions = [
    "plasma"
    "plasmax11"
  ];
}
