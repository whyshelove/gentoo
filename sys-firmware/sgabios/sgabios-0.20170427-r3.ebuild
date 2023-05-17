# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DPREFIX="module+"
suffix_ver=$(ver_cut 4)
VER_COMMIT=16781+9f4724c2
DSUFFIX=".8.0+${VER_COMMIT}"
WhatArch=noarch

inherit toolchain-funcs rhel8-a

DESCRIPTION="serial graphics adapter bios option rom for x86"
HOMEPAGE="https://code.google.com/p/sgabios/"

SRC_URI="
	!binary? ( ${SRC_URI} )
	binary? ( ${BIN_URI/-/-bin-} )"

S="${WORKDIR}/${P/0.}-gitcbaee52"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~alpha amd64 ~arm arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ppc64 ~s390 ~sparc x86"
IUSE="binary"
REQUIRED_USE="!amd64? ( !x86? ( binary ) )"

src_compile() {
	use binary && return

	tc-ld-disable-gold
	tc-export_build_env BUILD_CC
	emake -j1 \
		BUILD_CC="${BUILD_CC}" \
		BUILD_CFLAGS="${BUILD_CFLAGS}" \
		BUILD_LDFLAGS="${BUILD_LDFLAGS}" \
		BUILD_CPPFLAGS="${BUILD_CPPFLAGS}" \
		CC="$(tc-getCC)" \
		LD="$(tc-getLD)" \
		AR="$(tc-getAR)" \
		OBJCOPY="$(tc-getOBJCOPY)"
}

src_install() {
	use binary && rhel_bin_install && return

	insinto /usr/share/sgabios
	doins sgabios.bin
}
