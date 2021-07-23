# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools libtool

MY_P="${P/lib}"

DESCRIPTION="YAML 1.1 parser and emitter written in C"
HOMEPAGE="https://github.com/yaml/libyaml"
if [[ ${PV} == *8888 ]]; then
	inherit git-r3
	EGIT_REPO_URI="${CENTOS_GIT_REPO_URI}/${PN}.git"
	S="${WORKDIR}/${PN}"
else
	inherit rpm
	MY_PR=${PVR##*r}
	MY_PF=${P}-${MY_PR}
	SRC_URI="${BASEOS}/${MY_PF}${DIST}.src.rpm"
	S="${WORKDIR}/${MY_P}"
fi

LICENSE="MIT"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="doc static-libs test"
RESTRICT="!test? ( test )"

BDEPEND="doc? ( app-doc/doxygen )"

src_prepare() {
	default
	ls -la
	# conditionally remove tests
	if ! use test; then
		sed -i -e 's: tests::g' Makefile* || die
	fi

	elibtoolize
	eautoreconf
}

src_configure() {
	econf $(use_enable static-libs static)
}

src_compile() {
	emake all
	use doc && emake html
}

src_install() {
	use doc && HTML_DOCS=( doc/html/. )
	default
	find "${D}" -name '*.la' -delete || die
}
