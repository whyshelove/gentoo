# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit flag-o-matic optfeature portability rhel8

DESCRIPTION="A powerful light-weight programming language designed for extending applications"
HOMEPAGE="https://www.lua.org/"

LICENSE="MIT"
SLOT="5.3"
KEYWORDS="amd64 arm64 ~ppc64 ~s390"
IUSE="+deprecated readline"

DEPEND="
	>=app-eselect/eselect-lua-3
	readline? ( sys-libs/readline:= )
	!dev-lang/lua:0"
RDEPEND="${DEPEND}"
BDEPEND="virtual/pkgconfig"

src_configure() {
	use deprecated && append-cppflags -DLUA_COMPAT_5_1 -DLUA_COMPAT_5_2
	econf $(use_with readline) --with-compat-module

	sed -i 's|^hardcode_libdir_flag_spec=.*|hardcode_libdir_flag_spec=""|g' libtool
	sed -i 's|^runpath_var=LD_RUN_PATH|runpath_var=DIE_RPATH_DIE|g' libtool

	# Autotools give me a headache sometimes.
	sed -i 's|@pkgdatadir@|${_datadir}|g' src/luaconf.h.template
}

src_compile() {
	tc-export CC
	cd src && emake CC="${CC}" LIBS="-lm -ldl"
}

src_install() {
	default

	insinto ${rpm_macros_dir}
	doins "${WORKDIR}"/macros.lua

	find "${ED}" -name '*.la' -delete || die
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

	optfeature "Lua support for Emacs" app-emacs/lua-mode
}
