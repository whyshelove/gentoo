# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
DSUFFIX="_4"
inherit usr-ldscript rhel9

DESCRIPTION="Minimalistic netlink library"
HOMEPAGE="https://netfilter.org/projects/libmnl/"

LICENSE="LGPL-2.1"
SLOT="0/0.2.0"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux"
IUSE="examples static-libs"

src_configure() {
	econf $(use_enable static-libs static)
}

src_install() {
	default

	gen_usr_ldscript -a mnl

	find "${D}" -name '*.la' -delete || die

	if use examples; then
		find examples/ -name 'Makefile*' -delete || die
		dodoc -r examples/
		docompress -x /usr/share/doc/${PF}/examples
	fi
}
