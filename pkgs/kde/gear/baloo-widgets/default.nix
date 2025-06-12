{
  mkKdeDerivation,
  kio,
}:
mkKdeDerivation {
  pname = "baloo-widgets";
  extraNativeBuildInputs = [
    kio
  ];
  meta.mainProgram = "baloo_filemetadata_temp_extractor";
}
