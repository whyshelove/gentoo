# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit toolchain-funcs rhel8-a

if [[ ${PV} == "9999" ]] ; then
	EGIT_REPO_URI="https://github.com/crash-utility/crash.git"
	SRC_URI="http://ftp.gnu.org/gnu/gdb/gdb-7.6.tar.gz"
	EGIT_BRANCH="master"
	inherit git-r3
else
	KEYWORDS="-* ~alpha amd64 arm64 ~arm ~ia64 ~ppc64 ~s390 ~x86"
fi

DESCRIPTION="Red Hat crash utility; Kernel analysis utility for live systems, netdump, diskdump, kdump, LKCD or mcore dumpfiles"
HOMEPAGE="https://crash-utility.github.io/"

LICENSE="GPL-3"
SLOT="0"
IUSE=""
# there is no "make test" target, but there is a test.c so the automatic
# make rules catch it and tests fail
RESTRICT="test"
DEPEND="sys-libs/ncurses
	sys-libs/zlib
	dev-libs/lzo
	sys-devel/bison
	app-arch/snappy"

RDEPEND="sys-devel/binutils"

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
