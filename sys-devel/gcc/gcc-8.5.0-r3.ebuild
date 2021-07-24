# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

PATCH_VER="1"

inherit toolchain rhel

KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86"

RDEPEND=""
DEPEND="${RDEPEND}
	elibc_glibc? ( >=sys-libs/glibc-2.13 )
	>=${CATEGORY}/binutils-2.20"

if [[ ${CATEGORY} != cross-* ]] ; then
	PDEPEND="${PDEPEND} elibc_glibc? ( >=sys-libs/glibc-2.13 )"
fi

S="${WORKDIR}/${P}-20210514"

src_prepare() {
	default
}

src_configure() {
	toolchain_src_configure
	filter-flags -pipe -Wall -fexceptions -Werror=format-security -Wp,-D_FORTIFY_SOURCE=[12] -mfpmath=sse -m64 -m32
	append-flags -Wformat-security -mfpmath=sse -msse2
	append-cppflags -Wformat
	case "$CFLAGS" in
  	    *-fasynchronous-unwind-tables*)
    	    sed -i -e 's/-fno-exceptions /-fno-exceptions -fno-asynchronous-unwind-tables /' \
      	    libgcc/Makefile.in
    	    ;;
	esac
}

