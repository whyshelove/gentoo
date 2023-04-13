# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools toolchain-funcs rhel8

DESCRIPTION="Library for handling page faults in user mode"
HOMEPAGE="https://www.gnu.org/software/libsigsegv/"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~alpha amd64 arm ~arm64 ~hppa ~ia64 ppc ppc64 ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~x86-solaris"
IUSE=""

src_prepare() {
	default
	eautoreconf
}

src_configure () {
	econf --enable-shared --enable-static
}

src_test () {
	if [[ ${FEATURES} = *sandbox* ]] ; then
		# skip tests as they will fail
		ewarn "Skipped tests. Please disable sandbox to run tests."
		return 0
	fi
	emake check
}

src_install() {
	emake DESTDIR="${D}" install
	rm -f "${ED}/usr/$(get_libdir)"/*.la || die
	dodoc AUTHORS ChangeLog* NEWS PORTING README
}
