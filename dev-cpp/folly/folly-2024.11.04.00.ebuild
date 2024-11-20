# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

# These must be bumped together:
# dev-cpp/edencommon
# dev-cpp/fb303
# dev-cpp/fbthrift
# dev-cpp/fizz
# dev-cpp/folly
# dev-cpp/mvfst
# dev-cpp/wangle
# dev-util/watchman

inherit cmake

DESCRIPTION="An open-source C++ library developed and used at Facebook"
HOMEPAGE="https://github.com/facebook/folly"
SRC_URI="https://github.com/facebook/folly/releases/download/v${PV}/${PN}-v${PV}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~ppc64"
IUSE="llvm-libunwind test"
RESTRICT="!test? ( test )"

RDEPEND="
	app-arch/bzip2
	app-arch/lz4:=
	app-arch/snappy:=
	app-arch/xz-utils
	app-arch/zstd:=
	dev-cpp/fast_float:=
	dev-cpp/gflags:=
	dev-cpp/glog:=[gflags]
	dev-libs/boost:=[context]
	dev-libs/double-conversion:=
	dev-libs/libaio
	dev-libs/libevent:=
	dev-libs/libfmt:=
	dev-libs/libsodium:=
	dev-libs/openssl:=
	>=sys-libs/liburing-2.3:=
	sys-libs/zlib
	llvm-libunwind? ( sys-libs/llvm-libunwind:= )
	!llvm-libunwind? ( sys-libs/libunwind:= )
"
# libiberty is linked statically
DEPEND="
	${RDEPEND}
	sys-libs/binutils-libs
	test? ( dev-cpp/gtest )
"

PATCHES=(
	"${FILESDIR}"/${PN}-2024.11.04.00-musl-fix.patch
)

src_unpack() {
	# Workaround for bug #889420
	mkdir -p "${S}" || die
	cd "${S}" || die
	default
}

src_configure() {
	# TODO: liburing could in theory be optional but fails to link
	local mycmakeargs=(
		-DLIB_INSTALL_DIR="$(get_libdir)"

		-DBUILD_TESTS=$(usex test)

		# https://github.com/gentoo/gentoo/pull/29393
		-DCMAKE_LIBRARY_ARCHITECTURE=$(usex amd64 x86_64 ${ARCH})
	)

	cmake_src_configure
}

src_test() {
	CMAKE_SKIP_TESTS=(
		# Mysterious "invalid json" failure
		io_async_ssl_session_test.SSLSessionTest
		singleton_thread_local_test.SingletonThreadLocalDeathTest
		# TODO: All SIGSEGV, report upstream!
		'concurrency_concurrent_hash_map_test.*'
	)

	cmake_src_test
}
