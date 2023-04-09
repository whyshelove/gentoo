# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multilib-minimal rhel9

DESCRIPTION="Library for multiple-precision floating-point computations with exact rounding"
HOMEPAGE="https://www.mpfr.org/ https://gitlab.inria.fr/mpfr"

LICENSE="LGPL-2.1"
# This is a critical package; if SONAME changes, bump subslot but also add
# preserve-libs.eclass usage to pkg_*inst! See e.g. the readline ebuild.
SLOT="0/6" # libmpfr.so version
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="static-libs"

RDEPEND=">=dev-libs/gmp-5.0.0:=[${MULTILIB_USEDEP},static-libs?]"
DEPEND="${RDEPEND}"

HTML_DOCS=( doc/FAQ.html )

src_prepare() {
	default

	# 4.1.0_p13's patch10 patches a .texi file *and* the corresponding
	# info file. We need to make sure the info file is newer, so the
	# build doesn't try to run makeinfo. Won't be needed on next release.
	touch "${S}/doc/mpfr.info" || die
}

multilib_src_configure() {
	# bug #476336#19
	# Make sure mpfr doesn't go probing toolchains it shouldn't
	ECONF_SOURCE="${S}" \
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
	rm "${ED}"/usr/share/doc/${PF}/COPYING* || die

	if ! use static-libs ; then
		find "${ED}"/usr -name '*.la' -delete || die
	fi
}
