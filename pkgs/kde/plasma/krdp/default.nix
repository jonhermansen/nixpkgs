{
  lib,
  stdenv,
  mkKdeDerivation,
  replaceVars,
  openssl,
  pkg-config,
  qtwayland,
  qttools,
  freerdp,
  fetchpatch,
  wayland,
  wayland-protocols,
  kdeHostTools,
  epoll-shim,
  evdev-proto,
}:
mkKdeDerivation {
  pname = "krdp";

  patches = [
    (replaceVars ./hardcode-openssl-path.patch {
      openssl = lib.getExe openssl;
    })
    (fetchpatch {
      # support for freerdp3, can be dropped with krdp 6.4
      url = "https://invent.kde.org/plasma/krdp/-/merge_requests/69.patch";
      hash = "sha256-5x9JUbFTw/POxBW8G/BOlo/wtcUjPU9J1V/wba1EI/o=";
    })
    ./include-what-you-use.patch
  ];

  env = lib.optionalAttrs ((stdenv.cc.libcxx.isLLVM or false) && lib.versionOlder stdenv.cc.version "20") {
    # jthread and stop_token
    NIX_CFLAGS_COMPILE = "-fexperimental-library";
  };

  extraNativeBuildInputs = [
    pkg-config
    kdeHostTools
    qttools
    qtwayland
  ];
  extraBuildInputs = [
    qtwayland
    freerdp
    wayland
    wayland-protocols
  ] ++ lib.optionals stdenv.hostPlatform.isFreeBSD [
    epoll-shim
    evdev-proto
  ];
}
