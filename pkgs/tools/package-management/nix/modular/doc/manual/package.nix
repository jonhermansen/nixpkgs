{
  lib,
  mkMesonDerivation,
  runCommand,
  stdenv,

  meson,
  ninja,
  lowdown-unsandboxed,
  mdbook,
  jq,
  python3,
  rsync,
  json-schema-for-humans,
  nix-cli,

  # Configuration Options

  version,
}:

# When cross-compiling from Darwin, the build-time `nix eval --impure` used
# to generate doc fragments tries to stat /nix/var/nix/profiles/per-user/...
# and fails with EPERM under the darwin sandbox. We don't need the manual
# for the produced binary; produce empty stub outputs instead.
if stdenv.buildPlatform.isDarwin && stdenv.buildPlatform.system != stdenv.hostPlatform.system then
  (runCommand "nix-manual-${version}" {
    outputs = [ "out" "man" ];
    meta.platforms = lib.platforms.all;
  } ''
    mkdir -p $out $man
  '')
else

mkMesonDerivation (finalAttrs: {
  pname = "nix-manual";
  inherit version;

  workDir = ./.;

  # TODO the man pages should probably be separate
  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [
    meson
    ninja
    (lib.getBin lowdown-unsandboxed)
    mdbook
    jq
    python3
    rsync
  ]
  ++ lib.optionals (lib.versionAtLeast (lib.versions.majorMinor version) "2.33") [
    json-schema-for-humans
  ]
  ++ [
    nix-cli
  ];

  preConfigure = ''
    chmod u+w ./.version
    echo ${finalAttrs.version} > ./.version
  '';

  postInstall = ''
    mkdir -p ''$out/nix-support
    echo "doc manual ''$out/share/doc/nix/manual" >> ''$out/nix-support/hydra-build-products
  '';

  meta = {
    platforms = lib.platforms.all;
  };
})
