# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,8,9} )
inherit python-any-r1 autotools rhel8-a

DESCRIPTION="X keyboard configuration database"
HOMEPAGE="https://www.freedesktop.org/wiki/Software/XKeyboardConfig https://gitlab.freedesktop.org/xkeyboard-config/xkeyboard-config"

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://gitlab.freedesktop.org/xkeyboard-config/xkeyboard-config.git"
	inherit autotools git-r3
	# x11-misc/util-macros only required on live ebuilds
	LIVE_DEPEND=">=x11-misc/util-macros-1.18"
else
	KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~sparc-solaris ~x86-solaris"
fi

LICENSE="MIT"
SLOT="0"
IUSE=""

BDEPEND="
	${PYTHON_DEPS}
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig
"
RDEPEND=""
DEPEND="${LIVE_DEPEND}"

pkg_setup() {
	python-any-r1_pkg_setup
}

src_configure() {
	local econfargs=(
		--with-xkb-base="${EPREFIX}/usr/share/X11/xkb"
		--enable-compat-rules
		# do not check for runtime deps
		--disable-runtime-deps
		--with-xkb-rules-symlink=xorg
	)

	econf "${econfargs[@]}"
}
