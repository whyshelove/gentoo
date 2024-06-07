# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools flag-o-matic rhel8-a

DESCRIPTION="Fork of the json-c library, which is optimized for liblognorm processing"
HOMEPAGE="https://www.rsyslog.com/tag/libfastjson/"

LICENSE="MIT"
SLOT="0/4.3.0"
KEYWORDS="amd64 arm arm64 ~hppa ~ia64 ~ppc64 ~riscv sparc x86"
IUSE="static-libs"

BDEPEND=">=sys-devel/autoconf-archive-2015.02.04"

DOCS=( AUTHORS ChangeLog )

src_prepare() {
	default
	eautoreconf -iv
}

src_configure() {
	append-cflags -D_GNU_SOURCE

	local myeconfargs=(
		$(use_enable static-libs static)
		--disable-rdrand
		--enable-compile-warnings=yes
	)
	econf "${myeconfargs[@]}"
}

src_install() {
	default

	find "${ED}"/usr/lib* -name '*.la' -delete || die
}
