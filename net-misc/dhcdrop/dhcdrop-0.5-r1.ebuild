# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Effectively suppresses illegal DHCP servers on the LAN"
HOMEPAGE="http://www.netpatch.ru/dhcdrop.html"
SRC_URI="http://www.netpatch.ru/projects/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~mips ~x86"

IUSE="static"

RDEPEND="!static? ( net-libs/libpcap )"
DEPEND="static? ( net-libs/libpcap[static-libs] )
	${RDEPEND}"

DOCS=( AUTHORS ChangeLog INSTALL NEWS README )

PATCHES=(
	# Fix building with -flto, bug #861608
	"${FILESDIR}/${P}-lto.patch"
)

src_prepare() {
	# Fix building with clang, bug #731694
	sed -i \
		-e '/^PACKAGE_/s/"//g' \
		configure || die

	default
}

src_configure() {
	econf $(use static && echo "--enable-static-build")
}
