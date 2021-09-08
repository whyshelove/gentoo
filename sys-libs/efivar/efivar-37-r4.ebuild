# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit toolchain-funcs flag-o-matic rhel8

DESCRIPTION="Tools and library to manipulate EFI variables"
HOMEPAGE="https://github.com/rhinstaller/efivar"

LICENSE="GPL-2"
SLOT="0/1"
KEYWORDS="amd64 ~arm arm64 ~ia64 x86"

RDEPEND="dev-libs/popt"
DEPEND="${RDEPEND}
	>=sys-kernel/linux-headers-3.18
	virtual/pkgconfig
"

src_prepare() {
	default
}

src_configure() {
	append-cflags -flto
	append-ldflags -flto
	tc-export CC
	export CC_FOR_BUILD=$(tc-getBUILD_CC)
	tc-ld-disable-gold
	export libdir="/usr/$(get_libdir)"
	export bindir="/usr/bin"
	unset LIBS # Bug 562004

	if [[ -n ${GCC_SPECS} ]]; then
		# The environment overrides the command line.
		GCC_SPECS+=":${S}/gcc.specs"
	fi
}
