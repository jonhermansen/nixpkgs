{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  cmake,
  openssl,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "capnproto";
  version = "1.0.2";

  # release tarballs are missing some ekam rules
  src = fetchFromGitHub {
    owner = "capnproto";
    repo = "capnproto";
    rev = "v${version}";
    sha256 = "sha256-LVdkqVBTeh8JZ1McdVNtRcnFVwEJRNjt0JV2l7RkuO8=";
  };

  nativeBuildInputs = [ cmake ];
  propagatedBuildInputs = [
    openssl
    zlib
  ];

  patches = [(fetchpatch {
    url = "https://github.com/capnproto/capnproto/commit/25aee2a610e5665953df826b26e543d4d430dc37.patch";
    name = "bsd-ai_v4mapped.patch";
    hash = "sha256-QZ65FW8ti6/IUzozSmQ5Y5n/3/8EBU3ecUSmSKEa4w0=";
  })];

  # https://github.com/capnproto/capnproto/pull/1907
  # for openbsd compile errors
  postPatch = ''
    substituteInPlace c++/src/kj/cidr.c++ --replace-fail '__FreeBSD__' '__FreeBSD__ || __OpenBSD__'
    substituteInPlace c++/src/kj/async-unix.h --replace-fail '__OpenBSD__ ||' ""
  '';

  meta = with lib; {
    homepage = "https://capnproto.org/";
    description = "Cap'n Proto cerealization protocol";
    longDescription = ''
      Cap’n Proto is an insanely fast data interchange format and
      capability-based RPC system. Think JSON, except binary. Or think Protocol
      Buffers, except faster.
    '';
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = [ ];
  };
}
