# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs rhel-a

DESCRIPTION="Simplified Wrapper and Interface Generator"
HOMEPAGE="http://www.swig.org/ https://github.com/swig/swig"
SRC_URI="${REPO_URI}/${MY_PF}.module_el8.4.0+630+093f1851.src.rpm"

LICENSE="GPL-3+ BSD BSD-2"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="ccache doc pcre"
RESTRICT="test"

RDEPEND="
	pcre? ( dev-libs/libpcre )
	ccache? ( sys-libs/zlib )
"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

DOCS=( ANNOUNCE CHANGES CHANGES.current README TODO )

src_configure() {
	econf \
		PKGCONFIG="$(tc-getPKG_CONFIG)" \
		$(use_enable ccache) \
		$(use_with pcre)
}

src_install() {
	default

	if use doc; then
		docinto html
		dodoc -r Doc/{Devel,Manual}
	fi
}
