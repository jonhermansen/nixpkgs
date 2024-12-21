{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule {
  pname = "lsf";
  version = "0";

  src = fetchFromGitHub {
    owner = "rhelmot";
    repo = "lsf";
    rev = "315ccec3bc9d0624e3514b6c68f67220866f7648";
    hash = "sha256-azpIjHL5T/qZcS6F3aMPT9fmCJ2M29j5Y/Ffokg053k=";
  };

  vendorHash = "sha256-Yj5csyO/bdErGuAYmLJ8BaYJJ7sQoQCQ7di1wOjx4Zs=";

  meta = {
    description = "Userspace FreeBSD emulator for Linux";
    homepage = "https://github.com/rhelmot/lsf";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ rhelmot ];
    mainProgram = "lsf";
  };
}
