{ fetchzip, sourceData }:

# Using fetchFromGitHub from their mirror because it's a lot faster than their git server
# If you want you could fetchgit from "https://git.FreeBSD.org/src.git" instead.
# The update script still pulls directly from git.freebsd.org
fetchzip {
  url = "https://github.com/freebsd/freebsd-src/archive/c8918d6c7412fce87922e9bd7e4f5c7d7ca96eb7.tar.gz";
  inherit (sourceData) hash;
}
