# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit autotools flag-o-matic rhel9-a

DESCRIPTION="Fork of the json-c library, which is optimized for liblognorm processing"
HOMEPAGE="https://www.rsyslog.com/tag/libfastjson/"

LICENSE="MIT"
SLOT="0/4.3.0"
KEYWORDS="amd64 arm arm64 ~hppa sparc x86"
IUSE="static-libs"

DEPEND=">=sys-devel/autoconf-archive-2015.02.04"
RDEPEND=""

src_prepare() {
	default

	eautoreconf
}

src_configure() {
	append-cflags -D_GNU_SOURCE

	local myeconfargs=(
		--enable-compile-warnings=yes
		$(use_enable static-libs static)
		--disable-rdrand
	)

	econf "${myeconfargs[@]}"
}

src_install() {
	local DOCS=( AUTHORS ChangeLog )
	default

	find "${ED}"usr/lib* -name '*.la' -delete || die
}
