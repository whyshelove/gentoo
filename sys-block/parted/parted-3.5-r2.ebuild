# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

VERIFY_SIG_OPENPGP_KEY_PATH="${BROOT}"/usr/share/openpgp-keys/bcl.asc

inherit autotools rhel9

DESCRIPTION="Create, destroy, resize, check, copy partitions and file systems"
HOMEPAGE="https://www.gnu.org/software/parted/"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~loong ~mips ppc ppc64 ~riscv ~s390 sparc x86"
IUSE="+debug device-mapper nls readline"

# util-linux for libuuid
RDEPEND="
	>=sys-fs/e2fsprogs-1.27
	sys-apps/util-linux
	device-mapper? ( >=sys-fs/lvm2-2.02.45 )
	readline? (
		>=sys-libs/ncurses-5.7-r7:0=
		>=sys-libs/readline-5.2:0=
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	nls? ( >=sys-devel/gettext-0.12.1-r2 )
	virtual/pkgconfig
"

DOCS=(
	AUTHORS BUGS ChangeLog NEWS README THANKS TODO doc/{API,FAT,USER.jp}
)

PATCHES=(
	"${FILESDIR}"/${PN}-3.2-po4a-mandir.patch
	"${FILESDIR}"/${PN}-3.3-atari.patch
	# https://lists.gnu.org/archive/html/bug-parted/2022-02/msg00000.html
	"${FILESDIR}"/${PN}-3.4-posix-printf.patch
)

# false positive
QA_CONFIG_IMPL_DECL_SKIP="MIN"

src_prepare() {
	default

	# RHEL has 2.69 which works fine with the macros parted uses
	sed -i s/2.71/2.69/ configure.ac

	eautoreconf

	touch doc/pt_BR/Makefile.in || die
}

src_configure() {
	append-cflags -Wno-unused-but-set-variable

	local myconf=(
		$(use_enable debug)
		$(use_enable device-mapper)
		$(use_enable nls)
		$(use_with readline)
		--disable-rpath
		--disable-static
		--disable-gcc-warnings
	)
	econf "${myconf[@]}"
}

src_install() {
	default

	find "${ED}" -type f -name '*.la' -delete || die
}
