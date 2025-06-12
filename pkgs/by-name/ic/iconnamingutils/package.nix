{
  lib,
  stdenv,
  fetchurl,
  perl,
  buildPackages,
  librsvg,
}:

stdenv.mkDerivation rec {
  pname = "icon-naming-utils";
  version = "0.8.90";

  src = fetchurl {
    url = "http://tango.freedesktop.org/releases/${pname}-${version}.tar.gz";
    sha256 = "071fj2jm5kydlz02ic5sylhmw6h2p3cgrm3gwdfabinqkqcv4jh4";
  };

  buildInputs = [
    librsvg
  ];

  nativeBuildInputs = [
    (buildPackages.perl.withPackages (p: [ p.XMLSimple ]))
  ];

  meta = with lib; {
    homepage = "https://tango.freedesktop.org/Standard_Icon_Naming_Specification";
    platforms = platforms.unix;
    license = licenses.gpl2;
  };
}
