# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

XORG_DOC=doc
XORG_MULTILIB=yes
inherit xorg-3 autotools rhel9-a

DESCRIPTION="X.Org X Display Manager Control Protocol library"

KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"

RDEPEND="
	elibc_glibc? (
		|| ( >=sys-libs/glibc-2.34 dev-libs/libbsd[${MULTILIB_USEDEP}] )
	)
	!elibc_glibc? (
		dev-libs/libbsd[${MULTILIB_USEDEP}]
	)
"
DEPEND="${RDEPEND}
	x11-base/xorg-proto"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	local XORG_CONFIGURE_OPTIONS=(
		--disable-static
		$(use_enable doc docs)
		$(use_with doc xmlto)
		--without-fop
	)
	xorg-3_src_configure
}
