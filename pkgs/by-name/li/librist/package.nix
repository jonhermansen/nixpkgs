{
  stdenv,
  lib,
  fetchpatch,
  fetchFromGitLab,
  meson,
  ninja,
  pkg-config,
  cjson,
  cmocka,
  mbedtls,
}:

stdenv.mkDerivation rec {
  pname = "librist";
  version = "0.2.11";

  src = fetchFromGitLab {
    domain = "code.videolan.org";
    owner = "rist";
    repo = "librist";
    rev = "v${version}";
    hash = "sha256-xWqyQl3peB/ENReMcDHzIdKXXCYOJYbhhG8tcSh36dY=";
  };

  # avoid rebuild on Linux for now
  patches = lib.optionals stdenv.isDarwin [
    # https://code.videolan.org/rist/librist/-/issues/192
    ./no-brew-darwin.diff
  ] ++ lib.optionals stdenv.hostPlatform.isFreeBSD [
    (fetchpatch {
        url = "https://raw.githubusercontent.com/freebsd/freebsd-ports/a613e66a54d54251878412b74c1e99defdac4192/multimedia/librist/files/patch-meson.build";
        hash = "sha256-KRVuoQDsyOg+uRDzHzjo4l5u1rb1BoZZHYQ9dP+p7Gw=";
        extraPrefix = "";
    })
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    cjson
    cmocka
    mbedtls
  ];

  meta = with lib; {
    description = "Library that can be used to easily add the RIST protocol to your application";
    homepage = "https://code.videolan.org/rist/librist";
    license = with licenses; [
      bsd2
      mit
      isc
    ];
    maintainers = with maintainers; [ raphaelr ];
    platforms = platforms.all;
  };
}
