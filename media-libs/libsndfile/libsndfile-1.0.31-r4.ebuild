# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{8..9} pypy3 )

if [[ ${PV} == *9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/libsndfile/libsndfile.git"
else
	KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
fi
inherit python-any-r1 multilib-minimal autotools rhel9-a

DESCRIPTION="C library for reading and writing files containing sampled sound"
HOMEPAGE="https://libsndfile.github.io/libsndfile/"

LICENSE="LGPL-2.1"
SLOT="0"
IUSE="alsa minimal sqlite test"
RESTRICT="!test? ( test )"

RDEPEND="
	!minimal? (
		media-libs/flac:=[${MULTILIB_USEDEP}]
		media-libs/libogg:=[${MULTILIB_USEDEP}]
		media-libs/libvorbis:=[${MULTILIB_USEDEP}]
		media-libs/opus:=[${MULTILIB_USEDEP}]
	)
	alsa? ( media-libs/alsa-lib:= )
	sqlite? ( dev-db/sqlite )"
DEPEND="${RDEPEND}"
BDEPEND="
	virtual/pkgconfig
	test? ( ${PYTHON_DEPS} )"
if [[ ${PV} == *9999 ]]; then
	BDEPEND+="
		${PYTHON_DEPS}
		sys-devel/autogen
	"
fi

pkg_setup() {
	if use test || [[ ${PV} == *9999 ]]; then
		python-any-r1_pkg_setup
	fi
}

src_unpack() {
	rpm_src_unpack ${A}
}

src_prepare() {
	default
	eapply ${WORKDIR}/libsndfile-1.0.25-zerodivfix.patch

}

multilib_src_configure() {
	ECONF_SOURCE="${S}" econf \
		--disable-octave \
		--disable-static \
		--disable-werror \
		--enable-largefile \
		$(use_enable !minimal external-libs) \
		$(multilib_native_enable full-suite) \
		$(multilib_native_use_enable alsa) \
		$(multilib_native_use_enable sqlite) \
		PYTHON="${EPYTHON}"
}

multilib_src_install_all() {
	einstalldocs

	# no static archives
	find "${ED}" -name '*.la' -delete || die
}
