{
  lib,
  stdenv,
  fetchFromSourcehut,
  audit,
  pkg-config,
  libcap,
  gperf,
  meson,
  ninja,
  python3,
  getent,
  libcapSupport ? lib.meta.availableOn stdenv.hostPlatform libcap,
  auditSupport ? lib.meta.availableOn stdenv.hostPlatform audit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "basu";
  version = "0.2.1";

  src = fetchFromSourcehut {
    owner = "~emersion";
    repo = "basu";
    rev = "v${finalAttrs.version}";
    hash = "sha256-zIaEIIo8lJeas2gVjMezO2hr8RnMIT7iiCBilZx5lRQ=";
  };

  outputs = [
    "out"
    "dev"
    "lib"
  ];

  buildInputs = []
  ++ lib.optional libcapSupport libcap
  ++ lib.optional auditSupport audit
  ;

  nativeBuildInputs = [
    gperf
    pkg-config
    meson
    ninja
    python3
    getent
  ];

  preConfigure = ''
    pushd src/basic
    patchShebangs \
      generate-cap-list.sh generate-errno-list.sh generate-gperfs.py
    popd
  '';

  mesonFlags = [
    (lib.mesonEnable "libcap" libcapSupport)
    (lib.mesonEnable "audit" auditSupport)
  ];

  env = lib.optionalAttrs (stdenv.cc.bintools.isLLVM && lib.versionAtLeast stdenv.cc.bintools.version "17") {
    # https://todo.sr.ht/~emersion/basu/20
    NIX_LDFLAGS = "--undefined-version";
  };

  meta = {
    homepage = "https://sr.ht/~emersion/basu";
    description = "Sd-bus library, extracted from systemd";
    mainProgram = "basuctl";
    license = lib.licenses.lgpl21Only;
    maintainers = with lib.maintainers; [ ];
    platforms = lib.platforms.linux ++ lib.platforms.freebsd;
  };
})
