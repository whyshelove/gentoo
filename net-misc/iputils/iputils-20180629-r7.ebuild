# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# For released versions, we precompile the man/html pages and store
# them in a tarball on our mirrors.  This avoids ugly issues while
# building stages, and reduces dependencies.
# To regenerate man/html pages emerge iputils-99999999[doc] with
# EGIT_COMMIT set to release tag, all USE flags enabled and
# tar ${S}/doc folder.

EAPI="7"

inherit fcaps flag-o-matic toolchain-funcs rhel8

S="${WORKDIR}/${PN}-s${PV}"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux"

DESCRIPTION="Network monitoring tools including ping and ping6"
HOMEPAGE="https://wiki.linuxfoundation.org/networking/iputils"

LICENSE="BSD GPL-2+ rdisc"
SLOT="0"
IUSE="+arping caps clockdiff doc gcrypt idn ipv6 libressl nettle rarpd rdisc ssl static tftpd tracepath traceroute"

LIB_DEPEND="caps? ( sys-libs/libcap[static-libs(+)] )
	idn? ( net-dns/libidn2:=[static-libs(+)] )
	ipv6? (
		ssl? (
			gcrypt? ( dev-libs/libgcrypt:0=[static-libs(+)] )
			!gcrypt? (
				nettle? ( dev-libs/nettle[static-libs(+)] )
				!nettle? (
					libressl? ( dev-libs/libressl:0=[static-libs(+)] )
					!libressl? ( dev-libs/openssl:0=[static-libs(+)] )
				)
			)
		)
	)
"
RDEPEND="arping? ( !net-misc/arping )
	rarpd? ( !net-misc/rarpd )
	traceroute? ( !net-analyzer/traceroute )
	!static? ( ${LIB_DEPEND//\[static-libs(+)]} )"
DEPEND="${RDEPEND}
	static? ( ${LIB_DEPEND} )
	virtual/os-headers
"
src_configure() {
  	export CFLAGS="-fpie"

	export LDFLAGS="-pie -Wl,-z,relro,-z,now"
	use static && append-ldflags -static

	TARGETS=(
		ping
		$(for v in arping clockdiff rarpd rdisc tftpd tracepath ; do usev ${v} ; done)
	)
	if use ipv6 ; then
		TARGETS+=(
			$(usex traceroute 'traceroute6' '')
		)
	fi

	myconf=(
		USE_CRYPTO=no
		USE_GCRYPT=no
		USE_NETTLE=no
	)

	if use ipv6 && use ssl ; then
		myconf=(
			USE_CRYPTO=yes
			USE_GCRYPT=$(usex gcrypt)
			USE_NETTLE=$(usex nettle)
		)
	fi
}

src_compile() {
	tc-export CC
	emake \
		USE_CAP=$(usex caps) \
		USE_IDN=$(usex idn) \
		IPV4_DEFAULT=$(usex ipv6 'no' 'yes') \
		TARGETS="${TARGETS[*]}" \
		${myconf[@]}

	gcc -Wall $CFLAGS $LDFLAGS ifenslave.c -o ifenslave
	emake -C doc man

}

src_install() {
	into /
	dobin ping
	dosym ping /bin/ping4
	if use ipv6 ; then
		dosym ping /bin/ping6
		dosym ping.8 /usr/share/man/man8/ping6.8
	fi
	doman doc/ping.8

	if use arping ; then
		dobin arping
		doman doc/arping.8
	fi

	into /usr

	if use tracepath ; then
		dosbin tracepath
		doman doc/tracepath.8
		dosym tracepath /usr/sbin/tracepath4
	fi

	local u
	for u in clockdiff rarpd rdisc tftpd ; do
		if use ${u} ; then
			case ${u} in
			clockdiff) dobin ${u};;
			*) dosbin ${u};;
			esac
			doman doc/${u}.8
		fi
	done

	if use tracepath && use ipv6 ; then
		dosym tracepath /usr/sbin/tracepath6
		dosym tracepath.8 /usr/share/man/man8/tracepath6.8
	fi

	if use traceroute && use ipv6 ; then
		dosbin traceroute6
		doman doc/traceroute6.8
	fi

	if use rarpd ; then
		newinitd "${FILESDIR}"/rarpd.init.d rarpd
		newconfd "${FILESDIR}"/rarpd.conf.d rarpd
	fi

	dodoc INSTALL.md

	use doc && dodoc doc/*.html
}

pkg_postinst() {
	fcaps cap_net_raw \
		bin/ping \
		$(usex arping 'bin/arping' '') \
		$(usex clockdiff 'usr/bin/clockdiff' '')
}

