{
  mkKdeDerivation,
  qtwayland,
  pkg-config,
  xorg,
}:
mkKdeDerivation {
  pname = "kidletime";

  extraNativeBuildInputs = [ pkg-config qtwayland ];
  extraBuildInputs = [
    qtwayland
    xorg.libXScrnSaver
  ];
}
