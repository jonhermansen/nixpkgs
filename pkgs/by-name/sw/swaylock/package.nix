{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  scdoc,
  wayland-scanner,
  wayland,
  wayland-protocols,
  libxkbcommon,
  cairo,
  gdk-pixbuf,
  pam,
  wrapGAppsNoGuiHook,
  librsvg
}:

stdenv.mkDerivation rec {
  pname = "swaylock";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "swaywm";
    repo = "swaylock";
    tag = "v${version}";
    hash = "sha256-1+AXxw1gH0SKAxUa0JIhSzMbSmsfmBPCBY5IKaYtldg=";
  };

  strictDeps = true;
  depsBuildBuild = [ pkg-config ];
  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    scdoc
    wayland-scanner
    wrapGAppsNoGuiHook
    gdk-pixbuf
  ];
  buildInputs = [
    wayland
    wayland-protocols
    libxkbcommon
    cairo
    gdk-pixbuf
    pam
    librsvg
  ];

  mesonFlags = [
    "-Dpam=enabled"
    "-Dgdk-pixbuf=enabled"
    "-Dman-pages=enabled"
  ];

  # https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=275328
  # can likely be removed for freebsd 14.3
  postPatch = ''
    substituteInPlace $(grep -lr 200809L) --replace-fail 'define _POSIX_C_SOURCE 200809L' 'define _XOPEN_SOURCE 700'
  '';

  meta = with lib; {
    description = "Screen locker for Wayland";
    longDescription = ''
      swaylock is a screen locking utility for Wayland compositors.
      Important note: If you don't use the Sway module (programs.sway.enable)
      you need to set "security.pam.services.swaylock = {};" manually.
    '';
    inherit (src.meta) homepage;
    mainProgram = "swaylock";
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.freebsd;
    maintainers = with maintainers; [ primeos ];
  };
}
