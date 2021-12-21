# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit autotools portability toolchain-funcs rhel9

DESCRIPTION="A powerful light-weight programming language designed for extending applications"
HOMEPAGE="https://www.lua.org/"
TEST_PV="5.4.2"
TEST_P="${PN}-${TEST_PV}-tests"
if [[ ${PV} != *8888 ]]; then
	SRC_URI="${SRC_URI}
	test? ( https://www.lua.org/tests/${TEST_P}.tar.gz )"
fi

LICENSE="MIT"
SLOT="5.4"
KEYWORDS="~alpha amd64 arm arm64 hppa ~ia64 ~mips ppc ppc64 ~riscv ~s390 sparc x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris"
IUSE="+deprecated readline test test-complete"

COMMON_DEPEND="
	>=app-eselect/eselect-lua-3
	readline? ( sys-libs/readline:0= )
	!dev-lang/lua:0"
DEPEND="${COMMON_DEPEND}"
RDEPEND="${COMMON_DEPEND}"
BDEPEND="sys-devel/libtool"

RESTRICT="!test? ( test )"

WRAPPED_HEADERS=(
	/usr/include/lua${SLOT}/luaconf.h
)

PATCHES=(
	"${FILESDIR}"/lua-5.4.2-make.patch
)

src_prepare() {
	default
	# use glibtool on Darwin (versus Apple libtool)
	if [[ ${CHOST} == *-darwin* ]] ; then
		sed -i -e '/LIBTOOL = /s:/libtool:/glibtool:' \
			Makefile src/Makefile || die
	fi

	# correct lua versioning
	sed -i -e 's/\(LIB_VERSION = \)6:1:1/\10:0:0/' src/Makefile || die

	sed -i -e 's:\(/README\)\("\):\1.gz\2:g' doc/readme.html || die

	eautoreconf
}

src_configure() {
	econf \
		--with-readline \
		--with-compat-module

	sed -i 's|^hardcode_libdir_flag_spec=.*|hardcode_libdir_flag_spec=""|g' libtool
	sed -i 's|^runpath_var=LD_RUN_PATH|runpath_var=DIE_RPATH_DIE|g' libtool
	# Autotools give me a headache sometimes.
	sed -i 's|@pkgdatadir@|/usr/share|g' src/luaconf.h.template
}

src_compile() {
	tc-export CC

	# what to link to liblua
	liblibs="-lm -ldl"
	liblibs="${liblibs} $(dlopen_lib)"

	# what to link to the executables
	mylibs=
	use readline && mylibs="-lreadline"

	cd src

	local myCFLAGS=""
	use deprecated && myCFLAGS+="-DLUA_COMPAT_5_3 "
	use readline && myCFLAGS+="-DLUA_USE_READLINE "

	case "${CHOST}" in
		*-mingw*) : ;;
		*) myCFLAGS+="-DLUA_USE_LINUX " ;;
	esac

	emake CC="${CC}" CFLAGS="${myCFLAGS} ${CFLAGS}" \
			SYSLDFLAGS="${LDFLAGS}" \
			RPATH="${EPREFIX}/usr/$(get_libdir)/" \
			LUA_LIBS="${mylibs}" \
			LIB_LIBS="${liblibs}" \
			V=$(ver_cut 1-2)

}

src_install() {
	default
	DOCS="README"
	HTML_DOCS="doc/*.html doc/*.png doc/*.css doc/*.gif"
	einstalldocs
	newman doc/lua.1 lua${SLOT}.1
	newman doc/luac.1 luac${SLOT}.1
	find "${ED}" -name '*.la' -delete || die
	find "${ED}" -name 'liblua*.a' -delete || die
}

src_test() {
	debug-print-function ${FUNCNAME} "$@"
	cd "${WORKDIR}/lua-${TEST_PV}-tests" || die

	# Removing tests that fail under mock/koji
	sed -i.orig -e '
    	  /db.lua/d;
    	  /errors.lua/d;
    	  ' all.lua

	LD_LIBRARY_PATH=${D}/usr/lib64 ${D}/usr/bin/lua -e"_U=true" all.lua
}

pkg_postinst() {
	eselect lua set --if-unset "${PN}${SLOT}"

	if has_version "app-editor/emacs"; then
		if ! has_version "app-emacs/lua-mode"; then
			einfo "Install app-emacs/lua-mode for lua support for emacs"
		fi
	fi
}
