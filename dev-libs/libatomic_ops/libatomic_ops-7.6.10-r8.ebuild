# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multilib-minimal rhel-c

DESCRIPTION="Implementation for atomic memory update operations"
HOMEPAGE="https://github.com/ivmai/libatomic_ops/"
#SRC_URI="https://github.com/ivmai/${PN}/releases/download/v${PV}/${P}.tar.gz"

LICENSE="MIT boehm-gc GPL-2+"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

multilib_src_configure() {
	ECONF_SOURCE="${S}" econf \
		--disable-static \
		--enable-shared

	# kill rpath
	sed -i 's|^hardcode_libdir_flag_spec=.*|hardcode_libdir_flag_spec=""|g' libtool
	sed -i 's|^runpath_var=LD_RUN_PATH|runpath_var=DIE_RPATH_DIE|g' libtool
}

multilib_src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
