{
  mkKdeDerivation,
  qtsensors,
  dbus,
  kdeHostTools,
  kxmlgui,
}:
mkKdeDerivation {
  pname = "kscreen";

  extraNativeBuildInputs = [
    kdeHostTools
    kxmlgui
  ];

  extraBuildInputs = [
    qtsensors
  ];

  postFixup = ''
    substituteInPlace $out/share/kglobalaccel/org.kde.kscreen.desktop \
      --replace-fail dbus-send ${dbus}/bin/dbus-send
  '';
  meta.mainProgram = "kscreen-console";
}
