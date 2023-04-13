# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools flag-o-matic rhel8

DESCRIPTION="A file archival tool which can also read and write tar files"
HOMEPAGE="https://www.gnu.org/software/cpio/cpio.html"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 ~s390"
IUSE="nls"

PATCHES=(
	"${FILESDIR}"/${PN}-2.12-non-gnu-compilers.patch #275295
	"${FILESDIR}"/${PN}-2.12-gcc-10.patch #705900
)

src_prepare() {
	default
	eautoreconf -fi
}

src_configure() {
	append-cflags -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE -pedantic -fno-strict-aliasing -Wall

	econf \
		$(use_enable nls) \
		--bindir="${EPREFIX}"/bin \
		--with-rmt="${EPREFIX}"/usr/sbin/rmt
}
