# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# TODO: Add python support.

EAPI=7

inherit multilib-minimal rhel9

KEYWORDS="~alpha amd64 ~arm arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~riscv ~s390 ~sparc ~x86 ~amd64-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"

DESCRIPTION="HTTP/2 C Library"
HOMEPAGE="https://nghttp2.org/"

LICENSE="MIT"
SLOT="0/1.14" # <C++>.<C> SONAMEs
IUSE="cxx debug hpack-tools jemalloc static-libs test +threads utils xml"

RESTRICT="!test? ( test )"

SSL_DEPEND="
	>=dev-libs/openssl-1.0.2:0=[-bindist(-),${MULTILIB_USEDEP}]
"
RDEPEND="
	cxx? (
		${SSL_DEPEND}
		dev-libs/boost:=[${MULTILIB_USEDEP},threads(+)]
	)
	hpack-tools? ( >=dev-libs/jansson-2.5 )
	jemalloc? ( dev-libs/jemalloc:=[${MULTILIB_USEDEP}] )
	utils? (
		${SSL_DEPEND}
		>=dev-libs/libev-4.15[${MULTILIB_USEDEP}]
		>=sys-libs/zlib-1.2.3[${MULTILIB_USEDEP}]
		net-dns/c-ares:=[${MULTILIB_USEDEP}]
	)
	xml? ( >=dev-libs/libxml2-2.7.7:2[${MULTILIB_USEDEP}] )"
DEPEND="${RDEPEND}
	test? ( >=dev-util/cunit-2.1[${MULTILIB_USEDEP}] )"
BDEPEND="virtual/pkgconfig"

src_prepare() {
	default
	[[ ${PV} == 9999 ]] && eautoreconf
}

multilib_src_configure() {
	local myeconfargs=(
		--disable-examples
		--disable-failmalloc
		--disable-python-bindings
		--disable-werror
		--without-cython
		--without-spdylay
		$(use_enable cxx asio-lib)
		$(use_enable debug)
		$(multilib_native_use_enable hpack-tools)
		$(use_enable static-libs static)
		$(use_enable threads)
		$(multilib_native_use_enable utils app)
		$(multilib_native_use_with jemalloc)
		$(multilib_native_use_with xml libxml2)
	)
	ECONF_SOURCE="${S}" econf "${myeconfargs[@]}"

	# avoid using rpath
	sed -i libtool                              \
	    -e 's/^runpath_var=.*/runpath_var=/'    \
	    -e 's/^hardcode_libdir_flag_spec=".*"$/hardcode_libdir_flag_spec=""/'
}

multilib_src_install_all() {
	# will be installed via $$doc
	rm -f "${ED}${_datadir}/doc/nghttp2/README.rst"

	if ! use static-libs ; then
		find "${ED}"/usr -name '*.la' -delete || die
	fi
}
