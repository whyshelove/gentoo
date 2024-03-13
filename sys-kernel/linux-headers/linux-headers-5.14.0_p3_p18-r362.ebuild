# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

subrelease="$(ver_cut 7).1"
DPREFIX="${subrelease}."
DSUFFIX="_$(ver_cut 5)"

inherit unpacker rhel9-a

SRC_URI="amd64? ( ${BIN_URI} )
	arm64? (
		https://dl.rockylinux.org/pub/rocky/9/AppStream/aarch64/os/Packages/${DIST_PRE_SUF_CATEGORY}.0.1.aarch64.rpm
	)"

KEYWORDS="amd64 arm64 ~ppc64 ~s390"
SLOT="0"

src_install() {
	rhel_bin_install
}
