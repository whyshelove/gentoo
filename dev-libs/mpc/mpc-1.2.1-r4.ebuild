# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multilib-minimal rhel9-a

DESCRIPTION="A library for multiprecision complex arithmetic with exact rounding"
HOMEPAGE="http://mpc.multiprecision.org/"

LICENSE="LGPL-2.1"
SLOT="0/3" # libmpc.so.3
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="static-libs"

DEPEND=">=dev-libs/gmp-5.0.0:0=[${MULTILIB_USEDEP},static-libs?]
	>=dev-libs/mpfr-4.1.0:0=[${MULTILIB_USEDEP},static-libs?]"
RDEPEND="${DEPEND}"

multilib_src_configure() {
	ECONF_SOURCE=${S} econf $(use_enable static-libs static)

	# Get rid of undesirable hardcoded rpaths; workaround libtool reordering
	# -Wl,--as-needed after all the libraries.
	sed -e 's|^hardcode_libdir_flag_spec=.*|hardcode_libdir_flag_spec=""|g' \
	    -e 's|^runpath_var=LD_RUN_PATH|runpath_var=DIE_RPATH_DIE|g' \
	    -e 's|CC="\(g..\)"|CC="\1 -Wl,--as-needed"|' \
	    -i libtool
}

multilib_src_install_all() {
	einstalldocs
	find "${D}" -name '*.la' -delete || die
	rm -f "${ED}"/usr/share/info/dir
}
