# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit meson rhel8-a

KEYWORDS="amd64 arm64 ~ppc ppc64 x86"

SRC_URI="${REPO_URI}/${MY_PF}.module_el8.5.0+877+1c30e0c9.src.rpm"
DESCRIPTION="A TCP-IP emulator used to provide virtual networking services."
HOMEPAGE="https://gitlab.freedesktop.org/slirp/libslirp"

LICENSE="BSD"
SLOT="0"
IUSE="static-libs"

RDEPEND="dev-libs/glib:="

DEPEND="${RDEPEND}"

src_prepare() {
	echo "${PV}" > .tarball-version || die
	echo -e "#!${BASH}\necho -n \$(cat '${S}/.tarball-version')" > build-aux/git-version-gen || die
	default
}

src_configure() {
	local emesonargs=(
		-Ddefault_library=$(usex static-libs both shared)
	)
	meson_src_configure
}
