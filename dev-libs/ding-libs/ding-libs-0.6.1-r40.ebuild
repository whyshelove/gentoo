# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multilib-minimal autotools rhel8

DESCRIPTION="set of utility libraries (mostly used by sssd)"
HOMEPAGE="https://pagure.io/SSSD/ding-libs"

LICENSE="LGPL-3 GPL-3"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sparc ~x86 ~amd64-linux"
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="test? ( dev-libs/check )"
BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}"/0001-path_utils_ut-allow-single-as-well.patch
)

src_prepare() {
	default
	eautoreconf -ivf
}

multilib_src_configure() {
	ECONF_SOURCE="${S}" econf --disable-static
}

multilib_src_install_all() {
	einstalldocs

	# no static archives
	find "${ED}" -name '*.la' -delete || die
}
