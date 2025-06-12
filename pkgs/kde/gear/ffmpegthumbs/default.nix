{
  mkKdeDerivation,
  ffmpeg,
  kio,
  kdeHostTools,
}:
mkKdeDerivation {
  pname = "ffmpegthumbs";

  extraNativeBuildInputs = [
    kio
    kdeHostTools
  ];

  extraBuildInputs = [ ffmpeg ];
}
