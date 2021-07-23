# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

MY_PR=${PVR##*r}
MY_PF=${P}-${MY_PR}.1

inherit toolchain rhel

S="${WORKDIR}/${P}-20210623"

KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"

RDEPEND=""
BDEPEND="${CATEGORY}/binutils"

src_prepare() {
	toolchain_src_prepare

	filter-flags -pipe -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2
	append-cflags -Wformat-security  -Wp,-D_GLIBCXX_ASSERTIONS
	append-cppflags -Wformat -Wformat-security  -Wp,-D_GLIBCXX_ASSERTIONS
}
