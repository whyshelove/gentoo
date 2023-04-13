# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

suffix_ver=$(ver_cut 5)
[[ ${suffix_ver} ]] && DSUFFIX="_${suffix_ver}"

CMAKE_ECLASS=cmake

inherit cmake-multilib rhel8

DESCRIPTION="Extremely Fast Compression algorithm"
HOMEPAGE="https://github.com/lz4/lz4"

LICENSE="BSD-2 GPL-2"
# https://abi-laboratory.pro/tracker/timeline/lz4/
SLOT="0/r131"
KEYWORDS="amd64 arm64 ~ppc64 ~s390"
IUSE="static-libs"

CMAKE_USE_DIR=${S}/contrib/cmake_unofficial

multilib_src_configure() {
	local mycmakeargs=(
		-DBUILD_STATIC_LIBS=$(usex static-libs)
	)

	cmake_src_configure
}
