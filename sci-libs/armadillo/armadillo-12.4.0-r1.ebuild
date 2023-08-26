# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake toolchain-funcs multilib

DESCRIPTION="Streamlined C++ linear algebra library"
HOMEPAGE="https://arma.sourceforge.net"
SRC_URI="mirror://sourceforge/arma/${P}.tar.xz"

LICENSE="Apache-2.0"
SLOT="0/12"
KEYWORDS="amd64 ~arm ppc64 ~riscv ~x86 ~amd64-linux ~x86-linux"
IUSE="arpack blas doc examples lapack mkl superlu test"
RESTRICT="!test? ( test )"
REQUIRED_USE="test? ( arpack lapack superlu )"

#	atlas? ( sci-libs/atlas[lapack] )
RDEPEND="
	dev-libs/boost
	arpack? ( sci-libs/arpack )
	blas? ( virtual/blas )
	lapack? ( virtual/lapack )
	mkl? ( sci-libs/mkl )
	superlu? ( >=sci-libs/superlu-5.2 )
"
DEPEND="${RDEPEND}
	arpack? ( virtual/pkgconfig )
	blas? ( virtual/pkgconfig )
	lapack? ( virtual/pkgconfig )
"

PATCHES=(
	"${FILESDIR}/${PN}-12.0.1-extratests.patch"
)

src_prepare() {
	# avoid the automagic cmake macros...
	sed -i -e 's/^ *include(ARMA_Find/# No automagic include(ARMA_Find/g' CMakeLists.txt || die

	# ... except for mkl, since without a license it's hard to figure out what to do there
	if use mkl; then
		sed -i -e 's/^# No automagic include(ARMA_FindMKL)/include(ARMA_FindMKL)/g' CMakeLists.txt || die
	fi

	cmake_src_prepare
}

src_configure() {
	local mycmakeargs=(
		-DINSTALL_LIB_DIR="${EPREFIX}/usr/$(get_libdir)"
	)
	if use arpack; then
		mycmakeargs+=(
			-DARPACK_FOUND=ON
			-DARPACK_LIBRARY="$($(tc-getPKG_CONFIG) --libs arpack)"
		)
	else
		mycmakeargs+=(
			-DARPACK_FOUND=OFF
		)
	fi
#	if use atlas; then
#		local c=atlas-cblas l=atlas-clapack
#		$(tc-getPKG_CONFIG) --exists ${c}-threads && c+=-threads
#		$(tc-getPKG_CONFIG) --exists ${l}-threads && l+=-threads
#		mycmakeargs+=(
#			-DCBLAS_FOUND=ON
#			-DCBLAS_INCLUDE_DIR="$($(tc-getPKG_CONFIG) --cflags-only-I ${c} | sed 's/-I//')"
#			-DCBLAS_LIBRARIES="$($(tc-getPKG_CONFIG) --libs ${c})"
#			-DCLAPACK_FOUND=ON
#			-DCLAPACK_INCLUDE_DIR="$($(tc-getPKG_CONFIG) --cflags-only-I ${l} | sed 's/-I//')"
#			-DCLAPACK_LIBRARIES="$($(tc-getPKG_CONFIG) --libs ${l})"
#		)
#	fi
	if use blas; then
		mycmakeargs+=(
			-DBLAS_FOUND=ON
			-DBLAS_LIBRARIES="$($(tc-getPKG_CONFIG) --libs blas)"
		)
	else
		mycmakeargs+=(
			-DBLAS_FOUND=OFF
		)
	fi
	if use lapack; then
		mycmakeargs+=(
			-DLAPACK_FOUND=ON
			-DLAPACK_LIBRARIES="$($(tc-getPKG_CONFIG) --libs lapack)"
		)
	else
		mycmakeargs+=(
			-DLAPACK_FOUND=OFF
		)
	fi
	if use superlu; then
		mycmakeargs+=(
			-DSuperLU_FOUND=ON
			-DSuperLU_LIBRARY="$($(tc-getPKG_CONFIG) --libs superlu)"
			-DSuperLU_INCLUDE_DIR="$($(tc-getPKG_CONFIG) --cflags-only-I superlu | awk '{print $1}' | sed 's/-I//')"
		)
	else
		mycmakeargs+=(
			-DSuperLU_FOUND=OFF
		)
	fi

	cmake_src_configure
}

src_test() {
	cmake_src_test || die

	pushd tests2 > /dev/null
	emake \
		CXX="$(tc-getCXX)" \
		CXX_FLAGS="-I../include ${CXXFLAGS} -DARMA_USE_BLAS -DARMA_USE_LAPACK" \
		LIB_FLAGS="-L.. -larmadillo $($(tc-getPKG_CONFIG) --libs blas lapack)"
	LD_LIBRARY_PATH="..:${LD_LIBRARY_PATH}" ./main || die
	emake clean
	popd > /dev/null
}

src_install() {
	cmake_src_install

	dodoc README.md
	use doc && dodoc *pdf *html

	if use examples; then
		docinto examples
		dodoc -r examples/*
		docompress -x /usr/share/doc/${PF}/examples
	fi
}
