{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  buildPackages,
  autoreconfHook,
  gobject-introspection,
  gettext,
  zlib,
  glib,
  docbook_xml_dtd_412,
  docbook_xsl,
  libxslt,
  linux-pam,
  freebsd,
  udev,
  libdrm,
  xmlto,
  pmutils,
  libselinux,
  pkg-config,
  dbus,
  libX11,
  acl,
  polkit,
  gtk-doc,

  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ConsoleKit2";
  version = "1.2.6";

  src = if stdenv.hostPlatform.isFreeBSD then fetchFromGitHub {
    owner = "arrowd";
    repo = "ConsoleKit2";
    rev = "fbf7045c8d83b0c3f08535577aa2365bf9b250bf";
    hash = "sha256-1TY1H7TGVe1nHNCAnQnEo8zCkhL6Yet5RqsXhV0/Skc=";
  } else fetchFromGitHub {
    owner = "ConsoleKit2";
    repo = "ConsoleKit2";
    rev = finalAttrs.version;
    hash = "sha256-jRt3MnGfLoFaywnfvChLSz7Fi2ZBNWtLB4R02Pr6Bao=";
  };

  patches = lib.optionals stdenv.hostPlatform.isFreeBSD [
    (fetchpatch {
      url = "https://github.com/arrowd/ConsoleKit2/commit/c5e423dd9ac011c152eecd9d03da7ec83ef98677.patch";
      name = "x11-optional-freebsd.patch";
      revert = true;
      hash = "sha256-BbVntv2ISSRsNBjNj16dxWcaRVwHMe1hkdAzltgt45c=";
    })
  ] ++ [
    ./tty-dialect.patch
  ];

  outputs = [
    "out"
    "doc"
    "man"
  ];

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    glib
    xmlto
    docbook_xml_dtd_412
    docbook_xsl
    libxslt
    gtk-doc
  ] ++ lib.optionals withIntrospection [
    gobject-introspection
  ];

  buildInputs = [
    gettext
    zlib
    udev
    dbus
    libX11
    polkit
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    linux-pam
    libdrm
    pmutils
    libselinux
    acl
  ] ++ lib.optionals stdenv.hostPlatform.isFreeBSD [
    freebsd.libpam
  ];

  postPatch = ''
    sed -E -i -e 's@UDEVDIR=.*@UDEVDIR=${builtins.placeholder "out"}/lib/udev@g' configure.ac
  '';

  preAutoreconf = ''
    gtkdocize
  '';

  configureFlags = [
    "--enable-docbook-docs"
    "--enable-pam-module"
    "--with-pam-module-dir=${builtins.placeholder "out"}/lib/security"
    "ac_cv_file__sys_class_tty_tty0_active=${if stdenv.hostPlatform.isLinux then "y" else "n"}"
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [
    "--enable-udev-acl"
  ] ++ lib.optionals (stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    "--enable-tests"
  ];

  meta = {
    description = "ConsoleKit2 is a framework for defining and tracking users, login sessions, and seats";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ rhelmot ];
    platforms = lib.platforms.unix;
  };
})
