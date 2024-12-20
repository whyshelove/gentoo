# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ADA_COMPAT=( gcc_12 gcc_13 )
inherit ada multiprocessing

DESCRIPTION="A complete Web development framework"
HOMEPAGE="http://libre.adacore.com/tools/aws/"
SRC_URI="https://github.com/AdaCore/${PN}/archive/refs/tags/v${PV}.tar.gz
	-> ${P}.tar.gz
	https://github.com/AdaCore/templates-parser/archive/refs/tags/v${PV}.tar.gz
	-> templates-parser-${PV}.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="+shared ssl wsdl"

RDEPEND="dev-ada/gnatcoll-core:=[${ADA_USEDEP},shared?,static-libs]
	dev-ada/libgpr:=[${ADA_USEDEP},shared?,static-libs]
	dev-ada/xmlada:=[${ADA_USEDEP},shared?,static-libs]
	shared? (
		dev-ada/xmlada[static-pic]
		dev-ada/libgpr[static-pic]
		dev-ada/gnatcoll-core[static-pic]
	)
	wsdl? (
		dev-ada/libadalang:=[${ADA_USEDEP},static-libs]
		dev-ada/langkit:=[${ADA_USEDEP},static-libs]
		dev-ada/gnatcoll-bindings:=[${ADA_USEDEP},gmp,iconv,static-libs]
		dev-libs/gmp
	)
	ssl? ( dev-libs/openssl )
	!dev-ada/templates-parser"
DEPEND="${RDEPEND}
	dev-ada/gprbuild[${ADA_USEDEP}]"

REQUIRED_USE="${ADA_REQUIRED_USE}"

PATCHES=(
	"${FILESDIR}"/${PN}-2020-gentoo.patch
)

src_prepare() {
	default
	rmdir templates_parser || die
	mv ../templates-parser-${PV} templates_parser || die
}

src_configure() {
	emake -j1 setup prefix=/usr ZLIB=true XMLADA=true \
		GPRBUILD="/usr/bin/gprbuild -v" \
		ENABLE_SHARED=$(usex shared true false) \
		SOCKET=$(usex ssl openssl std) \
		LAL=$(usex wsdl true false) \
		PROCESSORS=$(makeopts_jobs) \
		SERVER_HTTP2=true \
		CLIENT_HTTP2=true
	sed -i \
		-e "/GPRBUILD/s:gprbuild:gprbuild -v:g" \
		-e "/GPRINSTALL/s:gprinstall:gprinstall -v:g" \
		makefile.conf || die
}

src_compile() {
	emake -j1
}

src_install() {
	emake -j1 install-lib-native DESTDIR="${D}"
	emake -j1 install-tools-native DESTDIR="${D}"
	einstalldocs

	rm -r "${D}"/usr/share/gpr/manifests || die
}
