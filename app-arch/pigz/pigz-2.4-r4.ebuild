# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs flag-o-matic rhel8

DESCRIPTION="A parallel implementation of gzip"
HOMEPAGE="https://www.zlib.net/pigz/"

LICENSE="ZLIB"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 ~s390"
IUSE="static symlink test"
RESTRICT="!test? ( test )"

LIB_DEPEND="sys-libs/zlib[static-libs(+)]"
RDEPEND="!static? ( ${LIB_DEPEND//\[static-libs(+)]} )"
DEPEND="${RDEPEND}
	static? ( ${LIB_DEPEND} )
	test? ( app-arch/ncompress )"

src_compile() {
	append-cflags -fpie -pie
	use static && append-ldflags -static
	emake CC="$(tc-getCC)" CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"
}

src_install() {
	dobin ${PN}
	dosym ${PN} /usr/bin/un${PN}
	dodoc README
	doman ${PN}.1

	if use symlink; then
		dosym ${PN} /usr/bin/gzip
		dosym un${PN} /usr/bin/gunzip
	fi
}
