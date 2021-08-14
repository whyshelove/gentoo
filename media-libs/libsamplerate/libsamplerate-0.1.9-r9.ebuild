# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit multilib-minimal rhel-a

DESCRIPTION="Secret Rabbit Code (aka libsamplerate) is a Sample Rate Converter for audio"
HOMEPAGE="https://libsndfile.github.io/libsamplerate/"

KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos"
LICENSE="BSD-2"
SLOT="0"
IUSE="test"
RESTRICT="!test? ( test )"

# Alsa/FFTW are only required for tests
# libsndfile is only used by examples and tests
DEPEND="
	test? (
		media-libs/alsa-lib[${MULTILIB_USEDEP}]
		media-libs/libsndfile[${MULTILIB_USEDEP}]
		sci-libs/fftw:3.0[${MULTILIB_USEDEP}]
	)"
BDEPEND="virtual/pkgconfig"

multilib_src_configure() {
	ECONF_SOURCE="${S}" econf \
		--disable-static \
		$(use_enable test fftw) \
		$(use_enable test sndfile)
}

multilib_src_install_all() {
	einstalldocs
	find "${ED}" -name '*.la' -type f -delete || die
}
