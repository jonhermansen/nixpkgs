{
  lib,
  stdenv,
  kdoctools,
  mkKdeDerivation,
  docbook_xml_dtd_45,
  docbook-xsl-nons,
  perl,
  perlPackages,
  libxml2,
}:
mkKdeDerivation {
  pname = "kdoctools";

  # Perl could be used both at build time and at runtime.
  extraNativeBuildInputs = [
    perl
    perlPackages.URI
    libxml2
  ] ++ lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    kdoctools
    kdoctools.devtools
  ];
  extraBuildInputs = [
    docbook_xml_dtd_45
    docbook-xsl-nons
  ];
  extraPropagatedBuildInputs = [
    perl
    perlPackages.URI
  ];

  extraCmakeFlags = lib.optionals (!stdenv.buildPlatform.canExecute stdenv.hostPlatform) [
    "-DDOCBOOKL10NHELPER_EXECUTABLE=docbookl10nhelper"
    "-DMEINPROC6_EXECUTABLE=meinproc6"
  ];

  postInstall = ''
    mkdir -p $devtools/bin
    cp bin/docbookl10nhelper $devtools/bin
  '';
}
