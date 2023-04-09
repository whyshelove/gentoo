# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic rhel9

DESCRIPTION="Super-useful stream editor"
HOMEPAGE="http://sed.sourceforge.net/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86"
IUSE="acl nls selinux static"

RDEPEND="
	!static? (
		acl? ( virtual/acl )
		nls? ( virtual/libintl )
		selinux? ( sys-libs/libselinux )
	)
"
DEPEND="${RDEPEND}
	static? (
		acl? ( virtual/acl[static-libs(+)] )
		nls? ( virtual/libintl[static-libs(+)] )
		selinux? ( sys-libs/libselinux[static-libs(+)] )
	)
"
BDEPEND="nls? ( sys-devel/gettext )"

src_configure() {
	use static && append-ldflags -static

	myconf+=(
		--without-included-regex
		$(use_enable acl)
		$(use_enable nls)
		$(use_with selinux)
		# rename to gsed for better BSD compatibility
		--program-prefix=g
	)
	econf "${myconf[@]}"
}

src_install() {
	default

	# symlink to the standard name
	dosym gsed /usr/bin/sed
	dosym gsed.1 /usr/share/man/man1/sed.1
}
