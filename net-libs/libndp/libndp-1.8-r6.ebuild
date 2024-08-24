# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
DSUFFIX="_4"
inherit gnome2 multilib-minimal rhel9

DESCRIPTION="Library for Neighbor Discovery Protocol"
HOMEPAGE="http://libndp.org"

LICENSE="LGPL-2.1+"
SLOT="0"

KEYWORDS="~alpha amd64 arm arm64 ~ia64 ppc ppc64 ~riscv ~sparc x86"

multilib_src_configure() {
	ECONF_SOURCE="${S}" \
	gnome2_src_configure \
		--disable-static \
		--enable-logging
}

multilib_src_install() {
	gnome2_src_install
}
