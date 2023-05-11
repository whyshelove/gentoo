# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{9..11} )
PYTHON_REQ_USE="threads(+)"
inherit waf-utils multilib-minimal python-single-r1 rhel9

DESCRIPTION="Samba tevent library"
HOMEPAGE="https://tevent.samba.org/"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~x86-linux"
IUSE="python test"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"
RESTRICT="test !test? ( test )"

TALLOC_VERSION="2.3.4"

RDEPEND="
	dev-libs/libbsd[${MULTILIB_USEDEP}]
	>=sys-libs/talloc-${TALLOC_VERSION}[${MULTILIB_USEDEP}]
	python? (
		${PYTHON_DEPS}
		>=sys-libs/talloc-${TALLOC_VERSION}[python,${PYTHON_SINGLE_USEDEP}]
	)
"
DEPEND="
	${RDEPEND}
	elibc_glibc? (
		net-libs/libtirpc[${MULTILIB_USEDEP}]
		net-libs/rpcsvc-proto
	)
	test? ( >=dev-util/cmocka-1.1.3 )
"
BDEPEND="
	${PYTHON_DEPS}
	virtual/pkgconfig
"

WAF_BINARY="${S}/buildtools/bin/waf"

pkg_setup() {
	python-single-r1_pkg_setup
	export PYTHONHASHSEED=1
}

check_samba_dep_versions() {
	actual_talloc_version=$(sed -En '/^VERSION =/{s/[^0-9.]//gp}' lib/talloc/wscript || die)
	if [[ ${actual_talloc_version} != ${TALLOC_VERSION} ]] ; then
		eerror "Source talloc version: ${TALLOC_VERSION}"
		eerror "Ebuild talloc version: ${actual_talloc_version}"
		die "Ebuild needs to fix TALLOC_VERSION!"
	fi
}

src_prepare() {
	default

	check_samba_dep_versions

	multilib_copy_sources
}

multilib_src_configure() {
	# When specifying libs for samba build you must append NONE to the end to
	# stop it automatically including things
	local bundled_libs="NONE"

	# We "use" bundled cmocka when we're not running tests as we're
	# not using it anyway. Means we avoid making users install it for
	# no reason. bug #802531
	if ! use test ; then
		bundled_libs="cmocka,${bundled_libs}"
	fi

	waf-utils_src_configure \
		--bundled-libraries="${bundled_libs}" \
		--builtin-libraries=replace \
		$(multilib_native_usex python '' '--disable-python')
}

multilib_src_compile() {
	# Need to avoid parallel building, this looks like the
	# best way with waf-utils/multiprocessing eclasses
	unset MAKEOPTS
	waf-utils_src_compile
}

multilib_src_install() {
	waf-utils_src_install

	multilib_is_native_abi && use python && python_domodule tevent.py
}

multilib_src_install_all() {
	insinto /usr/include
	doins tevent_internal.h
}
