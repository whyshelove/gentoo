# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multilib-minimal rhel

DESCRIPTION="library for multiple-precision floating-point computations with exact rounding"
HOMEPAGE="https://www.mpfr.org/"

LICENSE="LGPL-2.1"
SLOT="0/6" # libmpfr.so version
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="static-libs"

RDEPEND=">=dev-libs/gmp-5.0.0[${MULTILIB_USEDEP},static-libs?]"
DEPEND="${RDEPEND}"

HTML_DOCS=( doc/FAQ.html )

multilib_src_configure() {
	# Make sure mpfr doesn't go probing toolchains it shouldn't #476336#19
	ECONF_SOURCE=${S} \
		user_redefine_cc=yes \
		econf $(use_enable static-libs static) --disable-assert

	# Get rid of undesirable hardcoded rpaths; workaround libtool reordering
	# -Wl,--as-needed after all the libraries.
	sed -e 's|^hardcode_libdir_flag_spec=.*|hardcode_libdir_flag_spec=""|g' \
	    -e 's|^runpath_var=LD_RUN_PATH|runpath_var=DIE_RPATH_DIE|g' \
	    -e 's|CC="\(g..\)"|CC="\1 -Wl,--as-needed"|' \
	    -i libtool
}

multilib_src_install_all() {
	use static-libs || find "${ED}"/usr -name '*.la' -delete

}
