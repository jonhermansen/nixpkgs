{
  stdenv,
  lib,
  accountsservice-linux,
  buildPackages,
  gobject-introspection,
  coreutils,
  substituteAll,
  fetchFromGitLab,
  consolekit2,
  gettext,
  glib,
  polkit,
  dbus,

  withIntrospection ?
    lib.meta.availableOn stdenv.hostPlatform gobject-introspection
    && stdenv.hostPlatform.emulatorAvailable buildPackages,
}:
accountsservice-linux.overrideAttrs (orig: rec {
  version = "23.13.9";

  src = fetchFromGitLab {
    domain = "gitlab.freedesktop.org";
    owner = "arrowd";
    repo = "accountsservice";
    rev = "665c4390164f47283f234970087105e52245ae67";
    hash = "sha256-qzoek8WXjAFzFG6F0bk+cGvGRIdXuKcqLEzOyZBQHHU=";
  };

  patches = [
    # Hardcode dependency paths.
    (substituteAll ({
      src = ./fix-paths.patch;
      inherit coreutils;
    }))

    # Do not try to create directories in /var, that will not work in Nix sandbox.
    ../accountsservice-linux/no-create-dirs.patch

    # Disable mutating D-Bus methods with immutable /etc.
    ./Disable-methods-that-change-files-in-etc.patch

    # Do not ignore third-party (e.g Pantheon) extensions not matching FHS path scheme.
    # Fixes https://github.com/NixOS/nixpkgs/issues/72396
    ../accountsservice-linux/drop-prefix-check-extensions.patch

    # Detect DM type from config file.
    # `readlink display-manager.service` won't return any of the candidates.
    ../accountsservice-linux/get-dm-type-from-config.patch

  ];

  postPatch = ''
    echo -e '#!${stdenv.shell}\necho "${version}-nixpkgs"' >generate-version.sh
    sed -E -i -e '/wtmp changes/d' meson.build
  '';

  buildInputs = [
    dbus
    gettext
    glib
    polkit
    consolekit2
  ];

  mesonFlags = [
    "-Dadmin_group=wheel"
    "-Dconsolekit=true"
    "-Dgdmconffile=/etc/gdm/custom.conf"
    "-Dlightdmconffile=/etc/lightdm/lightdm.conf"
    "-Dlocalstatedir=/var"
    "-Dsystemdsystemunitdir=no"
    "-Dvapi=false"
    "-Dtests=false" # uses fgetpwent
    (lib.mesonBool "introspection" withIntrospection)
  ];

  meta =
    with lib;
    orig.meta
    // {
      platforms = platforms.freebsd;
    };
})
