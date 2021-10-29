# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools rhel8-a

DESCRIPTION="a C client library to the memcached server"
HOMEPAGE="https://libmemcached.org/libMemcached.html"


LICENSE="BSD"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm arm64 ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sparc ~x86 ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="debug libevent +sasl dtrace +memaslap test"

RESTRICT="!test? ( test )"

RDEPEND="
	net-misc/memcached
	dev-libs/cyrus-sasl
	libevent? ( dev-libs/libevent )"
DEPEND="${RDEPEND}
	dtrace? ( ddev-util/systemtap )"

PATCHES=(
	"${FILESDIR}"/debug-disable-enable-1.0.18.patch
	"${FILESDIR}"/continuum-1.0.18.patch
	"${FILESDIR}"/${P}-autotools.patch
	"${FILESDIR}"/${P}-disable-sphinx.patch
	"${FILESDIR}"/${P}-musl.patch
)

src_prepare() {
	default
	rm README.win32 || die
	eautoreconf
}

src_configure() {
	econf \
		--enable-sasl \
		--enable-libmemcachedprotocol \
		$(use_enable memaslap memaslap) \
		$(use_enable dtrace dtrace) \
		$(use_enable debug debug) \
		$(use_enable debug assert) \
		$(usex test --with-memcached=/usr/bin/memcached --with-memcached=false )
}

src_install() {
	default

	# https://bugs.gentoo.org/299330
	# remove manpage to avoid collision
	rm -f "${ED}"/usr/share/man/man1/memdump.* || die
	newman man/memdump.1 memcached_memdump.1

	find "${ED}" -name '*.la' -delete || die
}
