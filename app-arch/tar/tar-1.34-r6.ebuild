# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

SUFFIX="_1"
inherit rhel9

DESCRIPTION="Use this to make tarballs :)"
HOMEPAGE="https://www.gnu.org/software/tar/"

LICENSE="GPL-3+"
SLOT="0"
if [[ -z "$(ver_cut 3)" ]] || [[ "$(ver_cut 3)" -lt 90 ]] ; then
	KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~x64-cygwin ~amd64-linux ~x86-linux ~arm64-macos ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
fi
IUSE="acl minimal nls selinux xattr"

RDEPEND="
	acl? ( virtual/acl )
	selinux? ( sys-libs/libselinux )
"
DEPEND="${RDEPEND}
	xattr? ( elibc_glibc? ( sys-apps/attr ) )
"
BDEPEND="
	nls? ( sys-devel/gettext )
"
PDEPEND="
	app-alternatives/tar
"

src_configure() {
	local myeconfargs=(
		--with-lzma="xz --format=lzma"
		DEFAULT_RMT_DIR=/etc
		RSH=/usr/bin/ssh
		--bindir="${EPREFIX}"/bin
		--enable-backup-scripts
		--libexecdir="${EPREFIX}"/usr/sbin
		$(use_with acl posix-acls)
		$(use_enable nls)
		$(use_with selinux)
		$(use_with xattr xattrs)

		# autoconf looks for gtar before tar (in configure scripts), hence
		# in Prefix it is important that it is there, otherwise, a gtar from
		# the host system (FreeBSD, Solaris, Darwin) will be found instead
		# of the Prefix provided (GNU) tar
		--program-prefix=g
	)

	FORCE_UNSAFE_CONFIGURE=1 econf "${myeconfargs[@]}"
}

src_test() {
	rm -f $D/test/testsuite
	emake check || (
    	# get the error log
	set +x
	find -name testsuite.log | while read line; do
        	echo "=== $line ==="
        	cat "$line"
       		echo
	done
	false
	)
}

src_install() {
	default

	# a nasty yet required piece of baggage
	exeinto /etc
	doexe "${FILESDIR}"/rmt

	mv "${ED}"/usr/sbin/{gbackup,backup-tar} || die
	mv "${ED}"/usr/sbin/{grestore,restore-tar} || die
	mv "${ED}"/usr/sbin/{g,}backup.sh || die
	mv "${ED}"/usr/sbin/{g,}dump-remind || die

	if use minimal ; then
		find "${ED}"/etc "${ED}"/*bin/ "${ED}"/usr/*bin/ \
			-type f -a '!' -name gtar \
			-delete || die
	fi

	if ! use minimal; then
		dosym grmt /usr/sbin/rmt
	fi
	dosym grmt.8 /usr/share/man/man8/rmt.8
}

pkg_postinst() {
	# ensure to preserve the symlink before app-alternatives/tar
	# is installed
	if [[ ! -h ${EROOT}/bin/tar ]]; then
		ln -s gtar "${EROOT}/bin/tar" || die
	fi
}
