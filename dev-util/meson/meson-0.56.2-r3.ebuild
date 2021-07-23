# Copyright 2016-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
PYTHON_COMPAT=( python3_{7,8,9} )

if [[ ${PV} != *8888 ]]; then
	KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~x64-cygwin ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
fi

inherit distutils-r1 toolchain-funcs rhel-c

DESCRIPTION="Open source build system"
HOMEPAGE="https://mesonbuild.com/"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="
	test? (
		dev-libs/glib:2
		dev-libs/gobject-introspection
		dev-util/ninja
		dev-vcs/git
		sys-libs/zlib[static-libs(+)]
		virtual/pkgconfig
	)
"
PATCHES=(
	${WORKDIR}/meson-gcc11.patch
)


src_unpack() {
	rpm_unpack ${A} && unpack ${WORKDIR}/*.tar.*
}

python_prepare_all() {
	local disable_unittests=(
		# ASAN and sandbox both want control over LD_PRELOAD
		# https://bugs.gentoo.org/673016
		-e 's/test_generate_gir_with_address_sanitizer/_&/'

		# ASAN is unsupported on some targets
		# https://bugs.gentoo.org/692822
		-e 's/test_pch_with_address_sanitizer/_&/'

		# https://github.com/mesonbuild/meson/issues/7203
		-e 's/test_templates/_&/'

		# Broken due to python2 wrapper
		-e 's/test_python_module/_&/'
	)

	sed -i "${disable_unittests[@]}" run_unittests.py || die

	# Broken due to python2 script created by python_wrapper_setup
	rm -r "test cases/frameworks/1 boost" || die

	distutils-r1_python_prepare_all
}

src_test() {
	tc-export PKG_CONFIG
	if ${PKG_CONFIG} --exists Qt5Core && ! ${PKG_CONFIG} --exists Qt5Gui; then
		ewarn "Found Qt5Core but not Qt5Gui; skipping tests"
	else
		# https://bugs.gentoo.org/687792
		unset PKG_CONFIG
		distutils-r1_src_test
	fi
}

python_test() {
	# Remove Boost tests for now, because it requires Python 2
	rm -rf "test cases/frameworks/1 boost"
	# Remove MPI tests for now because it is complicated to run
	rm -rf "test cases/frameworks/17 mpi"
	export MESON_PRINT_TEST_OUTPUT=1
	(
		# test_meson_installed
		unset PYTHONDONTWRITEBYTECODE

		# test_cross_file_system_paths
		unset XDG_DATA_HOME

		# 'test cases/unit/73 summary' expects 80 columns
		export COLUMNS=80

		${EPYTHON} -u run_tests.py
	) || die "Testing failed with ${EPYTHON}"
}

python_install_all() {
	distutils-r1_python_install_all

	insinto /usr/share/vim/vimfiles
	doins -r data/syntax-highlighting/vim/{ftdetect,indent,syntax}
	insinto /usr/share/zsh/site-functions
	doins data/shell-completions/zsh/_meson

	insinto ${rpmmacrodir}/
	doins data/macros.${PN}
}
