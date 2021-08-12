# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86"
S="${WORKDIR}/wayland-${PV}"

inherit meson-multilib rhel9-a

DESCRIPTION="wayland-scanner tool"
HOMEPAGE="https://wayland.freedesktop.org/ https://gitlab.freedesktop.org/wayland/wayland"

LICENSE="MIT"
SLOT="0"

BDEPEND="virtual/pkgconfig"
RDEPEND="
	!<dev-libs/wayland-${PV}
	>=dev-libs/expat-2.1.0-r3:=[$MULTILIB_USEDEP]
"
DEPEND="${RDEPEND}"

multilib_src_configure() {
	local emesonargs=(
		-Ddocumentation=false
		-Ddtd_validation=false
		-Dlibraries=false
		-Dscanner=true
	)
	meson_src_configure
}
