# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="7"

inherit flag-o-matic toolchain-funcs rhel8-a

DESCRIPTION="Annotate and examine compiled binary files"
HOMEPAGE=""
LICENSE="GPLv3+"
SLOT="0"
KEYWORDS="amd64 arm64 ~ppc64 ~s390"
IUSE="debuginfod annocheck plugin_rebuild clangplugin"

RDEPEND="
	sys-devel/gcc
	clangplugin? (
		sys-devel/clang
		sys-devel/llvm[binutils-plugin]
		sys-apps/gawk
	)
"
DEPEND="
	${RDEPEND}
	annocheck? ( dev-libs/elfutils )
	debuginfod? ( dev-libs/elfutils[debuginfod,libdebuginfod] )
"

src_prepare() {
	default

	if ! use clangplugin ; then
		sed -i 's/CLANG_PLUGIN//g'  configure.ac || die
		sed -i 's/LLVM_PLUGIN//g'  configure.ac || die
	fi
}

src_configure() {
	ANNOBIN_GCC_PLUGIN_DIR=$(gcc --print-file-name=plugin)
	[[ $(tc-arch) == "amd64" ]] && export CLANG_TARGET_OPTIONS="-fcf-protection"

	if use plugin_rebuild ; then
		filter-flags '*-annobin-cc1'
	fi

	local myconf=(
		$(use_with debuginfod)
		$(use_with annocheck)
		--with-gcc-plugin-dir=${ANNOBIN_GCC_PLUGIN_DIR}
	)
	if use clangplugin ; then
		llvm_major=$(llvm-config --version | cut -f1 -d".")
		ln -s /usr/lib/llvm/${llvm_major}/include/* .

		myconf+=( --with-clang --with-llvm )

		local llvm_version=$(llvm-config --version) || die

		clang_plugin_dir=/usr/lib/clang/${llvm_version}/plugins
		llvm_plugin_dir=/usr/lib/llvm/${llvm_version}/plugins
	fi

	econf "${myconf[@]}"

}

src_compile() {
	emake V=1 VERBOSE=1
	# Rebuild the plugin(s), this time using the plugin itself!  This
	# ensures that the plugin works, and that it contains annotations
	# of its own.

	if use plugin_rebuild ; then

		OPTS="$CFLAGS $LDFLAGS"

		# Rebuild the plugin(s), this time using the plugin itself!  This
		# ensures that the plugin works, and that it contains annotations
		# of its own.
		cp gcc-plugin/.libs/annobin.so.0.0.0 ${T}/tmp_annobin.so
		make -C gcc-plugin clean
		BUILD_FLAGS="-fplugin=${T}/tmp_annobin.so"

		emake -C gcc-plugin CXXFLAGS="${OPTS} $BUILD_FLAGS"

		if use clangplugin ; then
			cp clang-plugin/annobin-for-clang.so ${T}/tmp_annobin.so
			emake -C clang-plugin all CXXFLAGS="${OPTS} $BUILD_FLAGS"

			cp llvm-plugin/annobin-for-llvm.so ${T}/tmp_annobin.so
			emake -C llvm-plugin all CXXFLAGS="${OPTS} $BUILD_FLAGS"

		fi
	fi
}

src_install() {
	emake DESTDIR="${D}" install PLUGIN_INSTALL_DIR="${D}"${llvm_plugin_dir}

	if use clangplugin ; then
		# Move the clang plugin to a seperate directory.
		dodir ${clang_plugin_dir}
		mv "${ED}"${llvm_plugin_dir}/annobin-for-clang.so "${ED}"${clang_plugin_dir}
	fi

	rm -f "${ED}"${_infodir}/dir

	QLIST="enable"
}
