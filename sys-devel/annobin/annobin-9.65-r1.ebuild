# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit autotools toolchain-funcs rhel-a

DESCRIPTION="Annotate and examine compiled binary files"
HOMEPAGE=""
LICENSE="GPLv3+"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="debug clang +annobin"

RDEPEND="
	sys-devel/gcc
	clang? (
		sys-devel/clang
		sys-devel/llvm
		sys-apps/gawk
	)
"
DEPEND="
	${RDEPEND}
"

src_prepare() {
	default
	if ! use clang ; then
		sed -i 's/CLANG_PLUGIN//g'  configure.ac || die
		sed -i 's/LLVM_PLUGIN//g'  configure.ac || die
	fi
}

src_configure() {
	ANNOBIN_GCC_PLUGIN_DIR=$(gcc --print-file-name=plugin)

	local myconf=(
		$(use_with debug debuginfod)
		--with-gcc-plugin-dir=${ANNOBIN_GCC_PLUGIN_DIR}
		--without-annocheck
	)
	if use clang ; then
		myconf+=( --with-clang --with-llvm )
		ANNOBIN_CLANG_PLUGIN_DIR=$(clang --print-search-dirs | gawk -e'BEGIN { FS = ":" } /libraries/ { print gensub(" =","",1,$2) } END { }')
	fi

	econf "${myconf[@]}"

}

src_compile() {
	emake
	# Rebuild the plugin(s), this time using the plugin itself!  This
	# ensures that the plugin works, and that it contains annotations
	# of its own.
	cp gcc-plugin/.libs/annobin.so.0.0.0 ${T}/tmp_annobin.so
	make -C gcc-plugin clean
	BUILD_FLAGS="-fplugin=${T}/tmp_annobin.so"

	use annobin && BUILD_FLAGS="$BUILD_FLAGS -fplugin=annobin -fplugin-arg-annobin-disable"

	emake -C gcc-plugin CXXFLAGS="${OPT_FLAGS} $BUILD_FLAGS"

	if use clang ; then
		cp clang-plugin/annobin-for-clang.so ${T}/tmp_annobin.so
		emake -C clang-plugin all CXXFLAGS="${OPT_FLAGS} $BUILD_FLAGS"

		cp llvm-plugin/annobin-for-llvm.so ${T}/tmp_annobin.so
		emake -C llvm-plugin all CXXFLAGS="${OPT_FLAGS} $BUILD_FLAGS"

	fi
}

src_install() {
	emake DESTDIR="${D}" install PLUGIN_INSTALL_DIR="${D}"${ANNOBIN_CLANG_PLUGIN_DIR}
	rm -f "${ED}"${_infodir}/dir
}
