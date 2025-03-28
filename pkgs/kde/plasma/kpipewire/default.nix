{
  mkKdeDerivation,
  qtquick3d,
  pkg-config,
  pipewire,
  ffmpeg,
  libgbm,
  libva,
  qtdeclarative,
}:
mkKdeDerivation {
  pname = "kpipewire";

  extraNativeBuildInputs = [ pkg-config qtdeclarative ];
  extraBuildInputs = [
    qtquick3d
    pipewire
    ffmpeg
    libgbm
    libva
  ];
}
