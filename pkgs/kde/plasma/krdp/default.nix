{
  lib,
  stdenv,
  mkKdeDerivation,
  replaceVars,
  openssl,
  pkg-config,
  qtkeychain,
  qtwayland,
  qttools,
  freerdp,
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
    qtkeychain
    qtwayland
    freerdp
    wayland
    wayland-protocols
  ] ++ lib.optionals stdenv.hostPlatform.isFreeBSD [
    epoll-shim
    evdev-proto
  ];
}
