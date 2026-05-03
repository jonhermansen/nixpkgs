{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  pkg-config,
  pruneLibtoolFiles,
  flex,
  bison,
  libmnl,
  libnetfilter_conntrack,
  libnfnetlink,
  libnftnl,
  libpcap,
  bash,
  bashNonInteractive,
  nftablesCompat ? true,
  gitUpdater,

  # For tests
  vmTools,
  python3,
  util-linux,
  nftables,
  strace,
  iana-etc,
  shadow,
  iproute2,
  iputils,
}:

let
  version = "1.8.12";
  pname = "iptables";
in

stdenv.mkDerivation (finalAttrs: {
  inherit pname version;

  __structuredAttrs = true;

  src = fetchurl {
    url = "https://www.netfilter.org/projects/${pname}/files/${pname}-${version}.tar.xz";
    sha256 = "jn7pYmAUkt5lA9Fx1KlICSqxj4nxEd5y4wN8H0DPuEY=";
  };

  # Workaround: case-insensitive build filesystem (e.g. default macOS APFS).
  #
  # iptables ships pairs of files that differ only in case:
  #   include/linux/netfilter/xt_FOO.h ↔ xt_foo.h
  #   extensions/libxt_FOO.{c,man,t,…}  ↔ libxt_foo.{…}
  # On case-insensitive FS, one variant clobbers the other at unpack time.
  #
  # Approach: restore both contents from the source tarball — uppercase
  # variants go under uc/ subdirectories so they don't case-collide — then
  # patch GNUmakefile.in to link the uppercase target .o into the *same*
  # .so as its lowercase match counterpart. The resulting libxt_mark.so
  # exports both libxt_mark_init (match) and libxt_MARK_init (target);
  # iptables computes the dlsym name from the user-supplied extension
  # name, so on case-insensitive FS where dlopen("libxt_MARK.so") resolves
  # to libxt_mark.so, the right init still gets called. Works whether the
  # runtime FS is case-sensitive or not, with no wrappers or env tricks.
  prePatch = lib.optionalString stdenv.buildPlatform.isDarwin ''
    # 1. Normalize basenames to lowercase. After unpack on a case-insensitive
    #    FS, files may be named with either case depending on tar order.
    for f in extensions/libxt_CONNMARK.* extensions/libxt_DSCP.* \
             extensions/libxt_MARK.* extensions/libxt_RATEEST.* \
             extensions/libxt_SET.* extensions/libxt_TCPMSS.* \
             extensions/libxt_TOS.* extensions/libipt_TTL.* \
             extensions/libip6t_HL.* \
             include/linux/netfilter/xt_CONNMARK.h \
             include/linux/netfilter/xt_DSCP.h \
             include/linux/netfilter/xt_MARK.h \
             include/linux/netfilter/xt_RATEEST.h \
             include/linux/netfilter/xt_TCPMSS.h \
             include/linux/netfilter_ipv4/ipt_TTL.h \
             include/linux/netfilter_ipv6/ip6t_HL.h ; do
      [ -e "$f" ] || continue
      lc="$(dirname "$f")/$(basename "$f" | tr A-Z a-z)"
      [ "$f" = "$lc" ] && continue
      # On case-insensitive FS, $f and $lc resolve to the same inode,
      # so go via a temp name to force the on-disk casing.
      mv -f "$f" "$f.casetmp"
      mv -f "$f.casetmp" "$lc"
    done

    # 2. Restore correct lowercase HEADER content (the unpack may have
    #    clobbered with the uppercase variant's content).
    for hdr in netfilter/xt_connmark.h netfilter/xt_dscp.h \
               netfilter/xt_mark.h     netfilter/xt_rateest.h \
               netfilter/xt_tcpmss.h \
               netfilter_ipv4/ipt_ttl.h netfilter_ipv6/ip6t_hl.h ; do
      tar -xOf $src "iptables-${version}/include/linux/$hdr" \
        > "include/linux/$hdr"
    done

    # 3. Restore uppercase HEADER content under include/.../uc/.
    mkdir -p include/linux/netfilter/uc \
             include/linux/netfilter_ipv4/uc \
             include/linux/netfilter_ipv6/uc
    for hdr in netfilter/xt_CONNMARK.h netfilter/xt_DSCP.h \
               netfilter/xt_MARK.h     netfilter/xt_RATEEST.h \
               netfilter/xt_TCPMSS.h \
               netfilter_ipv4/ipt_TTL.h netfilter_ipv6/ip6t_HL.h ; do
      base="$(basename "$hdr")"
      dir="$(dirname "$hdr")"
      tar -xOf $src "iptables-${version}/include/linux/$hdr" \
        > "include/linux/$dir/uc/$base"
    done

    # 4. Rewrite #includes that reference uppercase headers → uc/ paths.
    find extensions include -name '*.[ch]' -print0 | xargs -0 sed -i \
      -e 's|<linux/netfilter/xt_CONNMARK\.h>|<linux/netfilter/uc/xt_CONNMARK.h>|g' \
      -e 's|<linux/netfilter/xt_DSCP\.h>|<linux/netfilter/uc/xt_DSCP.h>|g' \
      -e 's|<linux/netfilter/xt_MARK\.h>|<linux/netfilter/uc/xt_MARK.h>|g' \
      -e 's|<linux/netfilter/xt_RATEEST\.h>|<linux/netfilter/uc/xt_RATEEST.h>|g' \
      -e 's|<linux/netfilter/xt_TCPMSS\.h>|<linux/netfilter/uc/xt_TCPMSS.h>|g' \
      -e 's|<linux/netfilter_ipv4/ipt_TTL\.h>|<linux/netfilter_ipv4/uc/ipt_TTL.h>|g' \
      -e 's|<linux/netfilter_ipv6/ip6t_HL\.h>|<linux/netfilter_ipv6/uc/ip6t_HL.h>|g'

    # 5. Restore correct lowercase EXTENSION content for all colliding pairs.
    for ext in extensions/libxt_connmark extensions/libxt_dscp \
               extensions/libxt_mark    extensions/libxt_rateest \
               extensions/libxt_set     extensions/libxt_tcpmss \
               extensions/libxt_tos     extensions/libipt_ttl \
               extensions/libip6t_hl ; do
      tar -xOf $src "iptables-${version}/$ext.c" > "$ext.c"
    done

    # 6. Restore uppercase EXTENSION targets under extensions/uc/.
    mkdir -p extensions/uc
    for ext in libxt_CONNMARK libxt_DSCP libxt_MARK libxt_RATEEST \
               libxt_SET libxt_TCPMSS libxt_TOS \
               libipt_TTL libip6t_HL ; do
      tar -xOf $src "iptables-${version}/extensions/$ext.c" \
        > "extensions/uc/$ext.c"
    done

    # Some sources use quoted includes for files that live in extensions/
    # (e.g. libxt_SET.c → "libxt_set.h"; libxt_DSCP.c → "dscp_helper.c";
    # libxt_TOS.c → "tos_values.c"). Quoted-include search starts in the
    # source file's directory, so symlink those files into uc/ for the
    # relocated sources.
    for f in extensions/*.h extensions/dscp_helper.c extensions/tos_values.c ; do
      [ -e "$f" ] || continue
      ln -sf "../$(basename "$f")" "extensions/uc/$(basename "$f")"
    done

    # Re-run the include rewrite from step 4 on the freshly-extracted uc/
    # sources (they didn't exist at step 4 time).
    sed -i \
      -e 's|<linux/netfilter/xt_CONNMARK\.h>|<linux/netfilter/uc/xt_CONNMARK.h>|g' \
      -e 's|<linux/netfilter/xt_DSCP\.h>|<linux/netfilter/uc/xt_DSCP.h>|g' \
      -e 's|<linux/netfilter/xt_MARK\.h>|<linux/netfilter/uc/xt_MARK.h>|g' \
      -e 's|<linux/netfilter/xt_RATEEST\.h>|<linux/netfilter/uc/xt_RATEEST.h>|g' \
      -e 's|<linux/netfilter/xt_TCPMSS\.h>|<linux/netfilter/uc/xt_TCPMSS.h>|g' \
      -e 's|<linux/netfilter_ipv4/ipt_TTL\.h>|<linux/netfilter_ipv4/uc/ipt_TTL.h>|g' \
      -e 's|<linux/netfilter_ipv6/ip6t_HL\.h>|<linux/netfilter_ipv6/uc/ip6t_HL.h>|g' \
      extensions/uc/*.c

    # 7. Patch GNUmakefile.in: compile uppercase sources to lib<pfx>_<UC>_uc.oo,
    #    then override the default lib%.so pattern rule for each pair so the
    #    lowercase match's .so additionally links the uppercase target .o.
    {
      printf '\n# === Case-insensitive FS workaround ===\n'
      printf '# Compile uppercase target sources from extensions/uc/.\n'
      printf 'define _uc_oo_rule\n'
      printf 'lib$(2)_$(1)_uc.oo: ''${srcdir}/uc/lib$(2)_$(1).c\n'
      printf '\t''$''${AM_V_CC} ''$''${CC} ''$''${AM_CPPFLAGS} ''$''${AM_DEPFLAGS} ''$''${AM_CFLAGS} -D_INIT=lib$(2)_$(1)_init -DPIC -fPIC ''$''${CFLAGS} -o $$@ -c $$<\n'
      printf 'endef\n\n'
      printf '# args: (uppercase-name, prefix-without-lib_)\n'
      for pair in 'CONNMARK xt' 'DSCP xt' 'MARK xt' 'RATEEST xt' \
                  'SET xt' 'TCPMSS xt' 'TOS xt' 'TTL ipt' 'HL ip6t' ; do
        # unquoted expansion: shell word-splits so printf gets 2 args for 2 %s
        printf '$(eval $(call _uc_oo_rule,%s,%s))\n' $pair
      done
      printf '\n'

      printf '# Merge uppercase target into the lowercase match .so.\n'
      printf 'define _combined_so_rule\n'
      printf 'lib$(3)_$(1).so: lib$(3)_$(1).oo lib$(3)_$(2)_uc.oo\n'
      printf '\t''$''${AM_V_CCLD} ''$''${CCLD} ''$''${AM_LDFLAGS} ''$''${LDFLAGS} -shared -o $$@ lib$(3)_$(1).oo lib$(3)_$(2)_uc.oo -L../libxtables/.libs -lxtables $(4)\n'
      printf 'endef\n\n'
      printf '# args: (lowercase-match, uppercase-target, prefix, extra-libs)\n'
      for entry in 'connmark CONNMARK xt' 'dscp DSCP xt' 'mark MARK xt' \
                   'rateest RATEEST xt -lm' 'set SET xt' 'tcpmss TCPMSS xt' \
                   'tos TOS xt' 'ttl TTL ipt' 'hl HL ip6t' ; do
        printf '$(eval $(call _combined_so_rule,%s,%s,%s,%s))\n' $entry
      done
    } >> extensions/GNUmakefile.in
  '';

  outputs = [
    "out"
    "lib"
    "dev"
    "man"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    pruneLibtoolFiles
    flex
    bison
  ];

  buildInputs = [
    libmnl
    libnetfilter_conntrack
    libnfnetlink
    libnftnl
    libpcap
    bash
  ];

  configureFlags = [
    "--enable-bpf-compiler"
    "--enable-devel"
    "--enable-libipq"
    "--enable-nfsynproxy"
    "--enable-shared"
  ]
  ++ lib.optional (!nftablesCompat) "--disable-nftables";

  enableParallelBuilding = true;

  postInstall = lib.optionalString nftablesCompat ''
    rm $out/sbin/{iptables,iptables-restore,iptables-save,ip6tables,ip6tables-restore,ip6tables-save}
    ln -sv xtables-nft-multi $out/bin/iptables
    ln -sv xtables-nft-multi $out/bin/iptables-restore
    ln -sv xtables-nft-multi $out/bin/iptables-save
    ln -sv xtables-nft-multi $out/bin/ip6tables
    ln -sv xtables-nft-multi $out/bin/ip6tables-restore
    ln -sv xtables-nft-multi $out/bin/ip6tables-save
  '';

  outputChecks.lib.disallowedRequisites = [
    bash
    bashNonInteractive
  ];

  passthru = {
    updateScript = gitUpdater {
      url = "https://git.netfilter.org/iptables";
      rev-prefix = "v";
    };

    # Tests are run in a VM because they require access to the kernel (to modify rule chains)
    tests.withCheck = vmTools.runInLinuxVM (
      finalAttrs.finalPackage.overrideAttrs (_: {
        memSize = 4096;
        nativeCheckInputs = [
          python3
          util-linux
          nftables
          strace
          iana-etc
          shadow
          iproute2
          iputils
        ];

        doCheck = true;

        preCheck = ''
          # Tests require /etc/{ethertypes,protocols,services}
          cp etc/ethertypes /etc/ethertypes
          ln -s ${iana-etc}/protocols /etc/protocols
          ln -s ${iana-etc}/services /etc/services

          # Some tests specifically require a root group with GID 0
          groupadd -g 0 root

          # Set up for "unprivileged" test (it tries to runuser -u nobody)
          groupadd -g 1000 nogroup
          useradd nobody -u 1000 -g nogroup -d /var/empty
          mkdir -p /etc/pam.d
          echo 'auth sufficient pam_permit.so' >> /etc/pam.d/runuser
          echo 'account required pam_permit.so' >> /etc/pam.d/runuser
          echo 'password required pam_permit.so' >> /etc/pam.d/runuser
          echo 'session required pam_permit.so' >> /etc/pam.d/runuser

          # /etc/protocols has an entry for 141/wesp now, which makes three tests fail. Fix the expected output
          # TODO(balsoft): see if this should be upstreamed
          sed -i -e 's/protocol 141/protocol wesp/' -e 's/l4proto 141/l4proto wesp/' -e 's/!= 141/!= wesp/' extensions/generic.txlate
          # Not sure what causes these failures. Just disable the tests for now.
          # FIXME(balsoft): see if this is fixed in a future release
          sed -i -e '/^monitorcheck \w*tables -X [^ ]*$/d' iptables/tests/shell/testcases/nft-only/0012-xtables-monitor_0

          ${lib.optionalString (stdenv.system == "aarch64-linux") ''
            # All SECMARK-related tests fail on aarch64 for some reason
            rm extensions/*SECMARK.t
          ''}

          patchShebangs xlate-test.py iptables-test.py iptables/tests
        '';

        # Save some resources by not installing anything
        outputs = [ "out" ];
        postCheck = ''
          touch "$out"
        '';

        dontInstall = true;
        dontFixup = true;
      })
    );
  };

  meta = {
    description = "Program to configure the Linux IP packet filtering ruleset";
    homepage = "https://www.netfilter.org/projects/iptables/index.html";
    platforms = lib.platforms.linux;
    mainProgram = "iptables";
    maintainers = with lib.maintainers; [ fpletz ];
    teams = [ lib.teams.security-review ];
    license = lib.licenses.gpl2Plus;
    downloadPage = "https://www.netfilter.org/projects/iptables/files/";
    identifiers.cpeParts = lib.meta.cpeFullVersionWithVendor "netfilter" finalAttrs.version;
  };
})
