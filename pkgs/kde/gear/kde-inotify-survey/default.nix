{
  mkKdeDerivation,
  kdeHostTools,
}:
mkKdeDerivation {
  pname = "kde-inotify-survey";

  extraNativeBuildInputs = [
    kdeHostTools
  ];

  meta.mainProgram = "kde-inotify-survey";
}
