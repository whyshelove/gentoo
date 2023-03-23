# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools flag-o-matic rhel9

DESCRIPTION="A file archival tool which can also read and write tar files"
HOMEPAGE="https://www.gnu.org/software/cpio/cpio.html"
SRC_URI+=" https://dev.gentoo.org/~sam/distfiles/${CATEGORY}/${PN}/${P}-CVE-2021-38185.patch.xz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="nls"

PDEPEND="
	app-alternatives/cpio
"

PATCHES=(
	"${FILESDIR}"/${PN}-2.13-wincompatible-function-pointer-types.patch
)

src_prepare() {
	default

	# Drop after 2.13 (only here for CVE patch)
	eautoreconf
}

src_configure() {
	append-cflags -D_GNU_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE -pedantic -fno-strict-aliasing

	local myeconfargs=(
		$(use_enable nls)
		--bindir="${EPREFIX}"/bin
		--with-rmt="${EPREFIX}"/etc/rmt
		# install as gcpio for better compatibility with non-GNU userland
		--program-prefix=g
	)

	econf "${myeconfargs[@]}"
}

src_compile() {
	emake
	(cd po && emake update-gmo)
}


src_test() {
	rm -f $D/test/testsuite
	emake check || {
    	echo "### TESTSUITE.LOG ###"
    	cat tests/testsuite.log
    	exit 1
	}
}

pkg_postinst() {
	# ensure to preserve the symlink before app-alternatives/cpio
	# is installed
	if [[ ! -h ${EROOT}/bin/cpio ]]; then
		ln -s gcpio "${EROOT}/bin/cpio" || die
	fi
}
