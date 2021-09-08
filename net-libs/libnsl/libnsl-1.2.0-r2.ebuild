# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multilib-minimal rhel8

DESCRIPTION="Public client interface for NIS(YP) and NIS+ in a IPv6 ready version"
HOMEPAGE="https://github.com/thkukuk/libnsl"
if [[ ${PV} != *8888 ]]; then
	SRC_URI="${BASEOS}/${MY_PF}.20180605git4a062cf${DIST}.src.rpm"
fi

SLOT="0/2"
LICENSE="LGPL-2.1+"

# Stabilize together with glibc-2.26!
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux"

IUSE="static-libs"

DEPEND="
	>=net-libs/libtirpc-1.1.0[${MULTILIB_USEDEP}]
"
RDEPEND="${DEPEND}
	!<sys-libs/glibc-2.26
"

src_unpack() {
	rpm_src_unpack ${A}
	mv libnsl-* $P
}

src_prepare() {
	default
	export CFLAGS="$CFLAGS"

	autoreconf -fiv
}

multilib_src_configure() {
	local myconf=(
		--enable-shared
		$(use_enable static-libs static)
	)
	ECONF_SOURCE=${S} econf "${myconf[@]}"
}

multilib_src_install_all() {
	einstalldocs
	find "${ED}" -type f -name '*.la' -delete || die
}
