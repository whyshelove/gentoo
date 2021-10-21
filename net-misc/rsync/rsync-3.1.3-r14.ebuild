# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit prefix systemd toolchain-funcs rhel8

DESCRIPTION="File transfer program to keep remote files into sync"
HOMEPAGE="https://rsync.samba.org/"

if [[ ${PV} == *8888 ]]; then
	PYTHON_COMPAT=( python3_{6,7,8} )
	inherit autotools python-any-r1
else
	KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
	S="${WORKDIR}/${P/_/}"
fi

LICENSE="GPL-3"
SLOT="0"
IUSE="acl examples iconv ipv6 stunnel xattr"

RDEPEND="acl? ( virtual/acl )
	xattr? ( kernel_linux? ( sys-apps/attr ) )
	>=dev-libs/popt-1.5
	iconv? ( virtual/libiconv )"
DEPEND="${RDEPEND}"

if [[ "${PV}" == *8888 ]] ; then
	BDEPEND="${PYTHON_DEPS}
		$(python_gen_any_dep '
			dev-python/commonmark[${PYTHON_USEDEP}]
		')"
fi

# Only required for live ebuild
python_check_deps() {
	has_version "dev-python/commonmark[${PYTHON_USEDEP}]"
}

src_prepare() {
	local PATCHES=(
		"${FILESDIR}/rsync-3.2.3-glibc-lchmod.patch"
	)
	default
	if [[ "${PV}" == *9999 ]] ; then
		eaclocal -I m4
		eautoconf -o configure.sh
		eautoheader && touch config.h.in
	fi
}

src_configure() {
	local myeconfargs=(
		--with-rsyncd-conf="${EPREFIX}"/etc/rsyncd.conf
		--without-included-popt
		$(use_enable acl acl-support)
		$(use_enable iconv)
		$(use_enable ipv6)
		$(use_enable xattr xattr-support)
	)

	if tc-is-cross-compiler; then
		# configure check is broken when cross-compiling.
		myeconfargs+=( --disable-simd )
	fi

	econf "${myeconfargs[@]}"
}

src_install() {
	emake DESTDIR="${D}" install

	newconfd "${FILESDIR}"/rsyncd.conf.d rsyncd
	newinitd "${FILESDIR}"/rsyncd.init.d-r1 rsyncd

	dodoc OLDNEWS README TODO tech_report.tex

	insinto /etc
	newins "${FILESDIR}"/rsyncd.conf-3.0.9-r1 rsyncd.conf

	insinto /etc/logrotate.d
	newins "${FILESDIR}"/rsyncd.logrotate rsyncd

	insinto /etc/xinetd.d
	newins "${FILESDIR}"/rsyncd.xinetd-3.0.9-r1 rsyncd

	# Install stunnel helpers
	if use stunnel ; then
		emake DESTDIR="${D}" install-ssl-daemon
	fi

	# Install the useful contrib scripts
	if use examples ; then
		exeinto /usr/share/rsync
		doexe support/*
		rm -f "${ED}"/usr/share/rsync/{Makefile*,*.c}
	fi

	eprefixify "${ED}"/etc/{,xinetd.d}/rsyncd*

	systemd_newunit "packaging/systemd/rsync.service" "rsyncd.service"
}

pkg_postinst() {
	if grep -Eqis '^[[:space:]]use chroot[[:space:]]*=[[:space:]]*(no|0|false)' \
		"${EROOT}"/etc/rsyncd.conf "${EROOT}"/etc/rsync/rsyncd.conf ; then
		ewarn "You have disabled chroot support in your rsyncd.conf.  This"
		ewarn "is a security risk which you should fix.  Please check your"
		ewarn "/etc/rsyncd.conf file and fix the setting 'use chroot'."
	fi
	if use stunnel ; then
		einfo "Please install \">=net-misc/stunnel-4\" in order to use stunnel feature."
		einfo
		einfo "You maybe have to update the certificates configured in"
		einfo "${EROOT}/etc/stunnel/rsync.conf"
	fi
}
