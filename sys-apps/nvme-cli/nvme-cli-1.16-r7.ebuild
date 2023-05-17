# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit systemd toolchain-funcs udev rhel8

DESCRIPTION="NVM-Express user space tooling for Linux"
HOMEPAGE="https://github.com/linux-nvme/nvme-cli"
RESTRICT="test"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm64 ppc64 ~riscv x86"
IUSE="hugepages systemd +uuid"

RDEPEND="hugepages? ( sys-libs/libhugetlbfs )
	systemd? ( sys-apps/systemd:= )
	uuid? ( sys-apps/util-linux:= )"
DEPEND="${RDEPEND}"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	default

	sed -e 's|^LIBUUID =|LIBUUID ?=|' \
		-e 's|^LIBJSONC =|LIBJSONC ?=|' \
		-e 's|^LIBHUGETLBFS =|LIBHUGETLBFS ?=|' \
		-e 's|^HAVE_SYSTEMD =|HAVE_SYSTEMD ?=|' \
		-e '/DESTDIROLD/d' \
		-i Makefile || die
}

src_configure() {
	tc-export CC

	export PREFIX="${EPREFIX}/usr"

	local unitdir="$(systemd_get_systemunitdir)"
	export SYSTEMDDIR="${unitdir%/system}"
	export UDEVDIR="${EPREFIX}$(get_udevdir)"

	MAKEOPTS+=" LIBUUID=$(usex uuid 0 1)"
	MAKEOPTS+=" LIBHUGETLBFS=$(usex hugepages 0 1)"
	MAKEOPTS+=" HAVE_SYSTEMD=$(usex systemd 0 1)"
	MAKEOPTS+="  V=1"
}
