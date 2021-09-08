# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit rhel8-a

DESCRIPTION="virtual Common Access Card (CAC) library emulator"
HOMEPAGE="https://www.spice-space.org/"
SRC_URI="${REPO_URI}/${MY_PF}.${DIST}_1.src.rpm"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~ia64 ppc ppc64 sparc x86"
IUSE="+passthrough static-libs"

RDEPEND=">=dev-libs/nss-3.13
	>=dev-libs/glib-2.22
	passthrough? ( >=sys-apps/pcsc-lite-1.8 )"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	default

	# remove test requiring SoftHSMv2 which is not in the tree atm
	sed -i \
		-e 's|tests/hwtests$(EXEEXT) \($(am__EXEEXT_1)\)|\1|' \
		Makefile.in || die
}

src_configure() {
	econf \
		$(use_enable passthrough pcsc) \
		$(use_enable static-libs static)
}

src_install() {
	default
	dodoc docs/*.txt
	use static-libs || find "${ED}"/usr/ -name 'lib*.la' -delete
}
