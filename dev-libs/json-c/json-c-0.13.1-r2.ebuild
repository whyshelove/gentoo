# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools rhel8

DESCRIPTION="A JSON implementation in C"
HOMEPAGE="https://github.com/json-c/json-c/wiki"

LICENSE="MIT"
SLOT="0/5"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="cpu_flags_x86_rdrand doc static-libs threads"

BDEPEND="doc? ( >=app-doc/doxygen-1.8.13 )"

src_unpack() {
	rhel_unpack ${A}
	sed -i "/%pretrans devel/d" ${WORKDIR}/*.spec
	rpmbuild --rmsource -bp $WORKDIR/*.spec --nodeps
	mv ${PN}-${P}-20180305 ${P}
}

src_configure() {
	local mycmakeargs=(
		-DBUILD_STATIC_LIBS=$(usex static-libs)
		-DDISABLE_WERROR=ON
		-DENABLE_RDRAND=$(usex cpu_flags_x86_rdrand)
		-DENABLE_THREADING=$(usex threads)
		--disable-silent-rules
		--enable-shared
	)

	econf mycmakeargs
}

src_test() {
	emake check
}

src_install() {
	default
	find ${ED} -name '*.a' -delete -print
	find ${ED} -name '*.la' -delete -print
	use doc && HTML_DOCS=( "${S}"/doc/html/. )
	einstalldocs
}
