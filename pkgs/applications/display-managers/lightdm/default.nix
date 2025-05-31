{
  lib,
  stdenv,
  buildPackages,
  fetchFromGitHub,
  nix-update-script,
  replaceVars,
  plymouth,
  pam,
  pkg-config,
  autoconf,
  automake,
  libtool,
  libxcb,
  glib,
  libXdmcp,
  itstool,
  intltool,
  libxklavier,
  libgcrypt,
  audit,
  busybox,
  freebsd,
  polkit,
  accountsservice,
  gtk-doc,
  gobject-introspection,
  vala,
  fetchpatch,
  withQt5 ? false,
  qtbase,
  yelp-tools,
  yelp-xsl,
  nixosTests,
  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:

stdenv.mkDerivation rec {
  pname = "lightdm";
  version = "1.32.0";

  outputs = [
    "out"
    "dev"
  ];

  src = fetchFromGitHub {
    owner = "canonical";
    repo = pname;
    rev = version;
    sha256 = "sha256-ttNlhWD0Ran4d3QvZ+PxbFbSUGMkfrRm+hJdQxIDJvM=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    yelp-tools
    yelp-xsl
    gtk-doc
    intltool
    itstool
    libtool
    pkg-config
  ] ++ lib.optionals withIntrospection [
    gobject-introspection
    vala
  ];

  buildInputs = [
    accountsservice
    glib
    libXdmcp
    libgcrypt
    libxcb
    libxklavier
    pam
    polkit
  ]
  ++ lib.optional (lib.meta.availableOn stdenv.hostPlatform audit) audit
  ++ lib.optional withQt5 qtbase;

  patches = [
    # Adds option to disable writing dmrc files
    (fetchpatch {
      url = "https://src.fedoraproject.org/rpms/lightdm/raw/4cf0d2bed8d1c68970b0322ccd5dbbbb7a0b12bc/f/lightdm-1.25.1-disable_dmrc.patch";
      sha256 = "06f7iabagrsiws2l75sx2jyljknr9js7ydn151p3qfi104d1541n";
    })
    (fetchpatch {
      url = "https://raw.githubusercontent.com/freebsd/freebsd-ports/4ac982fe4ac94aa2006c3946b2da7f8771f8b67d/x11/lightdm/files/patch-liblightdm-gobject_language.c";
      extraPrefix = "";
      hash = "sha256-1OGhiGDtgH2hCWQfHDV9XskiUHELHJiVZKTZAOQuK2k=";
    })
  ] ++ lib.optionals (lib.meta.availableOn stdenv.hostPlatform plymouth) [
    # Hardcode plymouth to fix transitions.
    # For some reason it can't find `plymouth`
    # even when it's in PATH in environment.systemPackages.
    (replaceVars ./fix-paths.patch {
      plymouth = "${plymouth}/bin/plymouth";
    })
  ] ++ lib.optionals stdenv.hostPlatform.isFreeBSD [
    (fetchpatch {
      url = "https://raw.githubusercontent.com/freebsd/freebsd-ports/4ac982fe4ac94aa2006c3946b2da7f8771f8b67d/x11/lightdm/files/patch-src_session-child.c";
      extraPrefix = "";
      hash = "sha256-PvWoBrjXN+6fYCr8a70VhKVHUk1a+CnfEzaKb+l4ClQ=";
    })
  ];

  dontWrapQtApps = true;

  preConfigure = "NOCONFIGURE=1 ./autogen.sh";

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--disable-tests"
    "--disable-dmrc"
  ] ++ lib.optional withQt5 "--enable-liblightdm-qt5";

  installFlags = [
    "sysconfdir=${placeholder "out"}/etc"
    "localstatedir=\${TMPDIR}"
  ];

  prePatch = ''
    substituteInPlace autogen.sh \
      --replace "which" "${buildPackages.busybox}/bin/which"

    substituteInPlace src/shared-data-manager.c \
      --replace /bin/rm ${if stdenv.hostPlatform.isFreeBSD then freebsd.bin else busybox}/bin/rm
  '';

  postInstall = ''
    rm -rf $out/etc/apparmor.d $out/etc/init $out/etc/pam.d
  '';

  passthru = {
    updateScript = nix-update-script { };
    tests = { inherit (nixosTests) lightdm; };
  };

  meta = with lib; {
    homepage = "https://github.com/canonical/lightdm";
    description = "Cross-desktop display manager";
    platforms = platforms.linux ++ platforms.freebsd;
    license = licenses.gpl3;
    teams = [ teams.pantheon ];
  };
}
