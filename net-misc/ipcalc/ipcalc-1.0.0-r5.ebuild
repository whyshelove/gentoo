# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson rhel

DESCRIPTION="IP Calculator prints broadcast/network/etc for an IP address and netmask"
LICENSE="GPL-2+"
HOMEPAGE="http://jodies.de/ipcalc"
KEYWORDS="~alpha amd64 arm ~hppa ~ia64 ~mips ppc ppc64 ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos"
SLOT="0"

DEPEND="dev-libs/libmaxminddb
	app-text/ronn"
RDEPEND=">=dev-lang/perl-5.6.0"

src_configure() {
	local emesonargs=(
		-Duse_maxminddb=enabled
		-Duse_runtime_linking=enabled
	)

	meson_src_configure
}
