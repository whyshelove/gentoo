# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=(python3_{6,8,9})

inherit multilib-minimal python-any-r1 rhel

DESCRIPTION="C library for the Public Suffix List"
HOMEPAGE="https://github.com/rockdaboot/libpsl"
#SRC_URI="https://github.com/rockdaboot/${PN}/releases/download/${P}/${P}.tar.gz"
LICENSE="MIT"
SLOT="0"

KEYWORDS="amd64 arm64 ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sparc ~x86"
IUSE="+icu +idn +man gtk-doc"

RDEPEND="
	icu? ( !idn? ( dev-libs/icu:=[${MULTILIB_USEDEP}] ) )
	idn? (
		dev-libs/libunistring[${MULTILIB_USEDEP}]
		net-dns/libidn2:=[${MULTILIB_USEDEP}]
	)
"

DEPEND="dev-python/publicsuffix
	${RDEPEND}
"
BDEPEND="
	${PYTHON_DEPS}
	dev-util/gtk-doc-am
	sys-devel/gettext
	virtual/pkgconfig
	man? ( dev-libs/libxslt )
"

multilib_src_configure() {
	local myeconfargs=(
		--disable-asan
		--disable-cfi
		--disable-ubsan
		--disable-static
		--with-psl-distfile=${_datadir}/publicsuffix/public_suffix_list.dafsa
		--with-psl-file=${_datadir}/publicsuffix/effective_tld_names.dat
		--with-psl-testfile=${_datadir}/publicsuffix/test_psl.txt
		$(use_enable man)
		$(use_enable gtk-doc)
	)

	# Prefer idn even if icu is in USE as well
	if use idn ; then
		myeconfargs+=(
			--enable-runtime=libidn2
		)
	elif use icu ; then
		myeconfargs+=(
			--enable-builtin=libicu
		)
	else
		myeconfargs+=( --disable-runtime )
	fi

	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"

	# avoid using rpath
	sed -i libtool \
	    -e 's|^\(runpath_var=\).*$|\1|' \
	    -e 's|^\(hardcode_libdir_flag_spec=\).*$|\1|'
}

multilib_src_install() {
	default

	find "${ED}" \( -name "*.a" -o -name "*.la" \) -delete || die
}
