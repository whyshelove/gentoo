# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

CMAKE_ECLASS=cmake
STAGE="unprep"
inherit cmake-multilib rhel9

DESCRIPTION="A JSON implementation in C"
HOMEPAGE="https://github.com/json-c/json-c/wiki"

LICENSE="MIT"
SLOT="0/5"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos"
IUSE="cpu_flags_x86_rdrand doc static-libs threads"

BDEPEND="doc? ( >=app-doc/doxygen-1.8.13 )"

MULTILIB_WRAPPED_HEADERS=(
	/usr/include/json-c/config.h
)

src_unpack() {
	rpmbuild_src_unpack ${A}
	sed -i "/# Update Doxyfile./,+1d" ${WORKDIR}/*.spec
	rpmbuild --rmsource -bp $WORKDIR/*.spec --nodeps
	mv ${PN}-${P}-20200419 ${P}
}

src_prepare() {
	# Update Doxyfile.
	use doc && doxygen -s -u doc/Doxyfile.in
	cmake_src_prepare
}

multilib_src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE:STRING=RELEASE
		-DCMAKE_C_FLAGS_RELEASE:STRING=""
		-DDISABLE_BSYMBOLIC:BOOL=OFF
		-G Ninja
		-DBUILD_STATIC_LIBS=$(usex static-libs)
		-DDISABLE_WERROR=ON
		-DENABLE_RDRAND=$(usex cpu_flags_x86_rdrand)
		-DENABLE_THREADING=$(usex threads)
	)

	cmake_src_configure
}

multilib_src_compile() {
	cmake_src_compile
}

multilib_src_test() {
	multilib_is_native_abi && cmake_src_test
}

multilib_src_install_all() {
	use doc && HTML_DOCS=( "${S}"/doc/html/. )
	einstalldocs
}
