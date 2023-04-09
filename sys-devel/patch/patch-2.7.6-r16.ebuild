# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

VERIFY_SIG_OPENPGP_KEY_PATH="${BROOT}"/usr/share/openpgp-keys/patch.asc
inherit flag-o-matic verify-sig autotools rhel9-a

DESCRIPTION="Utility to apply diffs to files"
HOMEPAGE="https://www.gnu.org/software/patch/patch.html"

SRC_URI+=" verify-sig? ( mirror://gnu/patch/${P}.tar.xz.sig )"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~loong ~m68k ~mips ~ppc ppc64 ~riscv ~s390 sparc x86 ~x64-cygwin ~amd64-linux ~x86-linux ~arm64-macos ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="static test xattr"
RESTRICT="!test? ( test )"

RDEPEND="xattr? ( sys-apps/attr )"
DEPEND="${RDEPEND}"
BDEPEND="test? ( sys-apps/ed )
	verify-sig? ( sec-keys/openpgp-keys-patch )"

PATCHES=(
	"${FILESDIR}"/${PN}-2.7.6-fix-error-handling-with-git-style-patches.patch
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	append-cflags -D_GNU_SOURCE

	use static && append-ldflags -static

	local myeconfargs=(
		$(use_enable xattr)
		# rename to gpatch for better BSD compatibility
		--program-prefix=g
	)
	# Do not let $ED mess up the search for `ed` 470210.
	ac_cv_path_ED=$(type -P ed) \
		econf "${myeconfargs[@]}"
}

src_install() {
	default

	# symlink to the standard name
	dosym gpatch /usr/bin/patch
	dosym gpatch.1 /usr/share/man/man1/patch.1
}
