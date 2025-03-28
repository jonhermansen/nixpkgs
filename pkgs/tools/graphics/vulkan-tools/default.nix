{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPackages,
  cmake,
  pkg-config,
  python3,
  glslang,
  libffi,
  libX11,
  libXau,
  libxcb,
  libXdmcp,
  libXrandr,
  vulkan-headers,
  vulkan-loader,
  vulkan-volk,
  wayland,
  wayland-protocols,
  wayland-scanner,
  moltenvk,
  AppKit,
  Cocoa,
  epoll-shim,
  evdev-proto,
}:

stdenv.mkDerivation rec {
  pname = "vulkan-tools";
  version = "1.4.304.0";

  src = fetchFromGitHub {
    owner = "KhronosGroup";
    repo = "Vulkan-Tools";
    rev = "vulkan-sdk-${version}";
    hash = "sha256-PtxzLsywYwaL4vhbDiabryLaMUMcwJGcL14dt8dnzvs=";
  };

  patches = [ ./wayland-scanner.patch ];

  nativeBuildInputs = [
    cmake
    pkg-config
    python3
    wayland-scanner
  ];

  buildInputs =
    [
      glslang
      vulkan-headers
      vulkan-loader
      vulkan-volk
    ]
    ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
      libffi
      libX11
      libXau
      libxcb
      libXdmcp
      libXrandr
      wayland
      wayland-protocols
      wayland-scanner
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      moltenvk
      moltenvk.dev
      AppKit
      Cocoa
    ]
    ++ lib.optionals stdenv.hostPlatform.isFreeBSD [
      epoll-shim
      evdev-proto
    ]
    ;

  libraryPath = lib.strings.makeLibraryPath [ vulkan-loader ];

  dontPatchELF = true;

  #preConfigure = lib.optionalString stdenv.hostPlatform.isFreeBSD ''
  #  export PKG_CONFIG_PATH_FOR_BUILD+=":${lib.getDev epoll-shim}/lib/pkgconfig"
  #'';

  env.PKG_CONFIG_WAYLAND_SCANNER_WAYLAND_SCANNER = lib.getExe buildPackages.wayland-scanner;
  env.PKG_CONFIG_WAYLAND_SCANNER_PKGDATADIR = "${buildPackages.wayland-scanner}/share/wayland";

  cmakeFlags =
    [
      # Don't build the mock ICD as it may get used instead of other drivers, if installed
      "-DBUILD_ICD=OFF"
      # vulkaninfo loads libvulkan using dlopen, so we have to add it manually to RPATH
      "-DCMAKE_INSTALL_RPATH=${libraryPath}"
      "-DGLSLANG_INSTALL_DIR=${glslang}"
      # Hide dev warnings that are useless for packaging
      "-Wno-dev"
    ]
    ++ lib.optionals stdenv.hostPlatform.isDarwin [
      "-DMOLTENVK_REPO_ROOT=${moltenvk}/share/vulkan/icd.d"
      # Don’t build the cube demo because it requires `ibtool`, which is not available in nixpkgs.
      "-DBUILD_CUBE=OFF"
    ];

  meta = with lib; {
    description = "Khronos official Vulkan Tools and Utilities";
    longDescription = ''
      This project provides Vulkan tools and utilities that can assist
      development by enabling developers to verify their applications correct
      use of the Vulkan API.
    '';
    homepage = "https://github.com/KhronosGroup/Vulkan-Tools";
    platforms = platforms.unix;
    license = licenses.asl20;
    maintainers = [ maintainers.ralith ];
  };
}
