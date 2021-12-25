# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs

# git.foss21.org is the official repository per upstream
DESCRIPTION="A skinny libtool implementation, written in C"
HOMEPAGE="https://git.foss21.org/slibtool"
if [[ "${PV}" == *9999 ]] ; then
	inherit git-r3
	EGIT_REPO_URI="https://git.foss21.org/slibtool"
else
	VERIFY_SIG_OPENPGP_KEY_PATH=${BROOT}/usr/share/openpgp-keys/midipix.asc
	inherit verify-sig

	SRC_URI="https://dl.midipix.org/slibtool/${P}.tar.xz"
	SRC_URI+=" verify-sig? ( https://dl.midipix.org/slibtool/${P}.tar.xz.sig )"

	KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x64-macos"

	BDEPEND="verify-sig? ( sec-keys/openpgp-keys-midipix )"
fi

LICENSE="MIT"
SLOT="0"

src_configure() {
	# Custom configure script (not generated by autoconf)
	./configure \
		--compiler=$(tc-getCC) \
		--host=${CHOST} \
		--prefix="${EPREFIX}"/usr \
			|| die
}
