{
php,
fetchFromGitHub,
buildNpmPackage,
}:

let
  pname = "coolify";
  version = "4.0.0-beta.420.6";
  src = fetchFromGitHub {
    owner = "coollabsio";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-Hkv1jH53ngg5z4QfAk3MT0wFWq/Llc3MEYeMnhyG2jU=";
  };
  staticAssets = buildNpmPackage {
    inherit pname version src;

    npmDepsHash = "sha256-S3wkS7L8hoS6e66+5NTv6xWHnm7RQza2e5FtvmaBvtU=";

    installPhase = ''
      mkdir -p "$out/public"
      cp -r public/build "$out/public"
    '';
  };
in
  php.buildComposerProject2 (finalAttrs: {
    inherit pname version src;

    composerNoDev = false;
    vendorHash = "sha256-YcV7CwZaVYu63TsYLwOpDxYYpMbY+5IOO9Ve/ytPBHg=";

    passthru = {
      inherit staticAssets;
    };

    postInstall = ''
      mkdir -p "$out"
      ln -s "${staticAssets}/public/build" "$out/share/php/coolify/public"
    '';
  })
