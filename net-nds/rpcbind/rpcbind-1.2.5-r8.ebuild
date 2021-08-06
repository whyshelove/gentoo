# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit systemd autotools rhel

KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~mips ppc ppc64 ~riscv ~s390 sparc x86"
DESCRIPTION="portmap replacement which supports RPC over various protocols"
HOMEPAGE="https://sourceforge.net/projects/rpcbind/"

LICENSE="BSD"
SLOT="0"
IUSE="debug remotecalls selinux systemd tcpd warmstarts"
REQUIRED_USE="systemd? ( warmstarts )"

DEPEND=">=net-libs/libtirpc-0.2.3:=
	systemd? ( sys-apps/systemd:= )
	tcpd? ( sys-apps/tcp-wrappers )"
RDEPEND="${DEPEND}
	selinux? ( sec-policy/selinux-rpcbind )"
BDEPEND="
	virtual/pkgconfig"

src_prepare() {
	default
	eautoreconf -fisv
}

src_configure() {
	local myeconfargs=(
		--bindir="${EPREFIX}"/sbin
		--sbindir="${EPREFIX}"/sbin
		--with-statedir="${EPREFIX}"/run/${PN}
		--with-rpcuser="rpc"
		--with-nss-modules="files altfiles"
		--with-systemdsystemunitdir=$(usex systemd "$(systemd_get_systemunitdir)" "no")
		$(use_enable debug)
		$(use_enable remotecalls rmtcalls)
		$(use_enable warmstarts)
		$(use_enable tcpd libwrap)
	)

	# Avoid using rpcsvc headers
	# https://bugs.gentoo.org/705224
	export ac_cv_header_rpcsvc_mount_h=no

	econf "${myeconfargs[@]}"
}

src_install() {
	default

	newinitd "${FILESDIR}"/${PN}.initd ${PN}
	newconfd "${FILESDIR}"/${PN}.confd ${PN}
	insinto /etc/sysconfig/
	newins "${WORKDIR}"/${PN}.sysconfig rpcbind
}

pkg_preinst() {
	# Softly static allocate the rpc uid and gid.
	getent group rpc >/dev/null || groupadd -f -g 32 -r rpc
	if ! getent passwd rpc >/dev/null ; then
		if ! getent passwd 32 >/dev/null ; then
		   useradd -l -c "Rpcbind Daemon" -d /var/lib/rpcbind  \
		      -g rpc -M -s /sbin/nologin -o -u 32 rpc > /dev/null 2>&1
		else
		   useradd -l -c "Rpcbind Daemon" -d /var/lib/rpcbind  \
		      -g rpc -M -s /sbin/nologin rpc > /dev/null 2>&1
		fi
	fi
}

pkg_postinst() {
	systemd_post rpcbind.service rpcbind.socket
}

pkg_prerm() {
	systemd_preun rpcbind.service rpcbind.socket
}

pkg_postrm() {
	systemd_postun_with_restart rpcbind.service rpcbind.socket
}
