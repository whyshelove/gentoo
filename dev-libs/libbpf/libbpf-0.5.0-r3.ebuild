# Copyright 2019-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic toolchain-funcs

if [[ ${PV} =~ [9]{4,} ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/libbpf/libbpf.git"
else
	inherit rhel9
	KEYWORDS="~alpha ~amd64 ~arm arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86"
fi
kver=5.14.0-13.el9
S="${WORKDIR}/linux-${kver}/tools/lib/bpf"

DESCRIPTION="Stand-alone build of libbpf from the Linux kernel"
HOMEPAGE="https://github.com/libbpf/libbpf"

LICENSE="GPL-2 LGPL-2.1 BSD-2"
SLOT="0/${PV}"
IUSE="+static-libs"

DEPEND="
	sys-kernel/linux-headers
	virtual/libelf"
RDEPEND="${DEPEND}"

src_configure() {
	append-cflags -fPIC
	append-ldflags '-Wl,--no-as-needed'
}

src_compile() {
	libbpf_ops=(
		prefix="${EPREFIX}/usr"
		DESTDIR="${D}"
		LIBSUBDIR="$(get_libdir)"
		LIBDIR=/${_libdir}
		CC="$(tc-getCC)"
		AR="$(tc-getAR)"
		V=1
		NO_PKG_CONFIG=1
	)

	emake "${libbpf_ops[@]}"
}

src_install() {
	emake "${libbpf_ops[@]}" install install_lib install_headers install_pkgconfig

	if ! use static-libs; then
		find "${ED}" -name '*.a' -delete || die
	fi

	insinto /usr/$(get_libdir)/pkgconfig
	doins ${PN}.pc
}
