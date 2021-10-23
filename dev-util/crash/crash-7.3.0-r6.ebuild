# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit toolchain-funcs rhel9-a

KEYWORDS="-* ~alpha amd64 arm64 ~arm ~ia64 ~ppc64 ~s390 ~x86"

DESCRIPTION="Red Hat crash utility; used for analyzing kernel core dumps"
HOMEPAGE="https://crash-utility.github.io/"

LICENSE="GPL-3"
SLOT="0"
IUSE=""
# there is no "make test" target, but there is a test.c so the automatic
# make rules catch it and tests fail
RESTRICT="test"
DEPEND="app-arch/snappy"

src_prepare() {
	sed -i -e "s|ar -rs|\${AR} -rs|g" Makefile || die
	ln -s "${WORKDIR}"/gdb-7.6.tar.gz . || die
	default
}

src_compile() {
	emake \
		CC="$(tc-getCC)" \
		AR="$(tc-getAR)" \
		CFLAGS="${CFLAGS}" LDFLAGS="${LDFLAGS}"
}

src_install() {
	default

	doman crash.8
	doheader defs.h
}
