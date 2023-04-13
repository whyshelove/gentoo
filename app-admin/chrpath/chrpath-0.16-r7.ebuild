# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools rhel8

DESCRIPTION="Chrpath can modify the rpath and runpath of ELF executables"
HOMEPAGE="https://directory.fsf.org/wiki/Chrpath"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 ~s390"

PATCHES=(
	"${FILESDIR}"/${P}-multilib.patch
	"${FILESDIR}"/${P}-testsuite-1.patch
	"${FILESDIR}"/${P}-solaris.patch
)

src_prepare() {
	default
	# disable installing redundant docs in the wrong dir
	sed -i -e '/doc_DATA/d' Makefile.am || die
	# fix for automake-1.13, #467538
	sed -i -e 's/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/' configure.ac || die
	eautoreconf
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
