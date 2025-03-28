{
  stdenv,
  lib,
  fetchFromGitLab,
  autoreconfHook,
  docbook_xsl,
  libxslt,
  meson,
  pkg-config,
  wrapGAppsHook3,
  python3,
  autoconf,
  automake,
  glib,
  gtk-doc,
  libtool,
  intltool,
  gitUpdater,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xfce4-dev-tools";
  version = "4.20.0";

  src = fetchFromGitLab {
    domain = "gitlab.xfce.org";
    owner = "xfce";
    repo = "xfce4-dev-tools";
    rev = "xfce4-dev-tools-${finalAttrs.version}";
    hash = "sha256-eUfNa/9ksLCKtVwBRtHaVl7Yl95tukUaDdoLNfeR+Ew=";
  };

  nativeBuildInputs = [
    autoreconfHook
    docbook_xsl
    libxslt # for xsltproc
    # x-d-t itself is not a meson project, but the xfce-do-release script wants
    # `meson rewrite kwargs`, thus this is checked by `AC_CHECK_PROGS`.
    meson
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    python3 # for xdt-gen-visibility
  ];

  propagatedBuildInputs = [
    autoconf
    automake
    glib
    gtk-doc
    intltool
    libtool
  ];

  dontUseMesonConfigure = true;
  configureFlags = [ "--enable-maintainer-mode" ];

  enableParallelBuilding = true;

  postPatch = lib.optionalString (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    sed -E -i -e '/tests/d' configure.ac Makefile.am
    substituteInPlace Makefile.am --replace-fail "xdt-csource \\" "xdt-csource"
  '';

  preConfigure = lib.optionalString stdenv.hostPlatform.isFreeBSD ''
    mkdir -p $TMP/bin
    ln -s $(type -p sed) $TMP/bin/gsed
    ln -s $(type -p make) $TMP/bin/gmake
    export PATH=$PATH:$TMP/bin
  '';

  setupHook = ./setup-hook.sh;

  passthru.updateScript = gitUpdater {
    rev-prefix = "xfce4-dev-tools-";
    odd-unstable = true;
  };

  meta = with lib; {
    homepage = "https://gitlab.xfce.org/xfce/xfce4-dev-tools";
    description = "Autoconf macros and scripts to augment app build systems";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ ] ++ teams.xfce.members;
    platforms = platforms.linux ++ platforms.freebsd;
  };
})
