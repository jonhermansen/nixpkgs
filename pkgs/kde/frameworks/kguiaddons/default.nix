{
  mkKdeDerivation,
  qtwayland,
  pkg-config,
}:
mkKdeDerivation {
  pname = "kguiaddons";

  extraNativeBuildInputs = [ pkg-config qtwayland ];
  extraBuildInputs = [ qtwayland ];
  meta.mainProgram = "kde-geo-uri-handler";
}
