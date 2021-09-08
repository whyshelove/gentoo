# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit toolchain-funcs rhel8-p

if [[ ${PV} == 8888* ]] ; then
	EGIT_REPO_URI="$EGIT_REPO_URI https://github.com/yasm/yasm.git"
	inherit autotools
else
	KEYWORDS="amd64 ~arm64 ~ppc64 x86 ~amd64-linux ~x86-linux ~x64-macos ~x64-solaris ~x86-solaris"
fi

DESCRIPTION="An assembler for x86 and x86_64 instruction sets"
HOMEPAGE="https://yasm.tortall.net/"

LICENSE="BSD-2 BSD || ( Artistic GPL-2 LGPL-2 )"
SLOT="0"
IUSE="nls"

BDEPEND="
	nls? ( sys-devel/gettext )
"
DEPEND="
	nls? ( virtual/libintl )
"
RDEPEND="${DEPEND}
"

if [[ ${PV} == 8888* ]]; then
	BDEPEND+="
		app-text/xmlto
		app-text/docbook-xml-dtd:4.1.2
		dev-lang/python
	"
fi

src_prepare() {
	default

	if [[ ${PV} == 8888* ]]; then
		eautoreconf
		python modules/arch/x86/gen_x86_insn.py || die
	fi
}

src_configure() {
	local myconf=(
		CC_FOR_BUILD="$(tc-getBUILD_CC)"
		CCLD_FOR_BUILD="$(tc-getBUILD_CC)"
		--disable-warnerror
		--disable-python
		--disable-python-bindings
		$(use_enable nls)
	)

	econf "${myconf[@]}"
}

src_test() {
	# https://bugs.gentoo.org/718870
	emake -j1 check
}
