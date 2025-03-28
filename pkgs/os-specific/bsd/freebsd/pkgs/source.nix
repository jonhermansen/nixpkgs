{ fetchgit, sourceData }:

# Using fetchFromGitHub from their mirror because it's a lot faster than their git server
# If you want you could fetchgit from "https://git.FreeBSD.org/src.git" instead.
# The update script still pulls directly from git.freebsd.org
fetchgit {
  url = "https://git.FreeBSD.org/src.git";
  inherit (sourceData) rev hash;
}
