# Copyright 2019-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic toolchain-funcs rhel8

if [[ ${PV} =~ [9]{4,} ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/libbpf/libbpf.git"
else
	KEYWORDS="~alpha ~amd64 arm arm64 ~hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86"
fi

kver=4.18.0-329.el8
S="${WORKDIR}/linux-${kver}/tools/lib/bpf"

HOMEPAGE="https://github.com/libbpf/libbpf"
DESCRIPTION="Stand-alone build of libbpf from the Linux kernel"

LICENSE="GPL-2 LGPL-2.1 BSD-2"
SLOT="0/${PV}"
IUSE="+static-libs"

COMMON_DEPEND="
	virtual/libelf
"
DEPEND="
	${COMMON_DEPEND}
	sys-kernel/linux-headers
"
RDEPEND="
	${COMMON_DEPEND}
"

src_compile() {
	append-cflags -fPIC
	libbpf_ops=(
		prefix="${EPREFIX}/usr"
		EXTRA_CFLAGS="${CFLAGS}"
		EXTRA_LDFLAGS="${LDFLAGS}"
		DESTDIR="${D}"
		BUILD_SHARED=y
		LIBSUBDIR="$(get_libdir)"
		CC="$(tc-getCC)"
		AR="$(tc-getAR)"
		V=1
	)

	emake "${libbpf_ops[@]}"
	
}

src_install() {
	emake "${libbpf_ops[@]}" install install_lib install_headers install_pkgconfig

	insinto /usr/$(get_libdir)/pkgconfig
	doins ${PN}.pc

	if ! use static-libs; then
		find "${D}" -name '*.a' -delete || die
	fi

}
