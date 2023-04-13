# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

suffix_ver=$(ver_cut 5)
DPREFIX="module+"
[[ ${suffix_ver} ]] && DSUFFIX=".${suffix_ver}.0+8303+4bdcb5c6"

inherit toolchain-funcs rhel8-a

DESCRIPTION="Simplified Wrapper and Interface Generator"
HOMEPAGE="http://www.swig.org/ https://github.com/swig/swig"

LICENSE="GPL-3+ BSD BSD-2"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 ~s390"
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
