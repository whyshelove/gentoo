# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools rhel8

DESCRIPTION="mokutil provides a tool to manage keys for Secure Boot through the MoK (Machine's Own Keys) mechanism."
HOMEPAGE="https://github.com/lcp/mokutil"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 arm64 ~x86"

DEPEND="dev-libs/openssl:=
	sys-libs/efivar:=
	sys-boot/gnu-efi
	virtual/libcrypt:="
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	default
	eautoreconf
}
